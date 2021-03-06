<?php
defined('PLA_PATH') or die('Hacking attempt!');
 
global $template, $page;

$page['active_menu'] = get_active_menu('updates');

include_once(PLA_PATH . 'include/functions.inc.php');
include_once(PHPWG_ROOT_PATH . 'admin/include/plugins.class.php');
$plugins = new plugins();

/* SELECT */
if (!isset($_GET['plugin_id']))
{
  $template->assign(array(
    'PLA_STEP' => 'select',
    'PLA_PLUGINS' => $plugins->fs_plugins,
    'F_ACTION' => PLA_ADMIN.'&amp;config',
    ));
}

/* CONFIG */
else if (isset($_GET['config']))
{
  $files = list_plugin_files($_GET['plugin_id']);
  $language_files = list_plugin_languages_files($_GET['plugin_id']);
  $default_lang_files = get_loaded_in_main($_GET['plugin_id']);
  
  if (empty($default_lang_files))
  {
    $default_lang_files = count($language_files)==1 ? array_keys($language_files) : (
                            array_key_exists('plugin.lang', $language_files) ? array('plugin.lang') : array()
                            );
  }
  
  if (file_exists(PLA_DATA.$_GET['plugin_id'].'.php'))
  {
    $saved_files = include(PLA_DATA.$_GET['plugin_id'].'.php');
  }
  else
  {
    $saved_files = array();
  }
  
  global $language_files, $default_lang_files;
  populate_plugin_files($files, $saved_files);

  $template->assign(array(
    'PLA_STEP' => 'config',
    'PLA_PLUGIN' => $plugins->fs_plugins[ $_GET['plugin_id'] ],
    'PLA_FILES' => $files,
    'PLA_LANG_FILES' => array_keys($language_files),
    'F_ACTION' => PLA_ADMIN.'&amp;plugin_id='.$_GET['plugin_id'].'&amp;analyze',
    'U_BACK' => PLA_ADMIN,
    ));
}

/* ANALYSIS */
else if (isset($_GET['analyze']))
{
  // save
  if (isset($_POST['files']))
  {
    $files = $_POST['files'];
    clean_files_from_config($files);
    
    $content = "<?php\nreturn ";
    $content.= var_export($files, true);
    $content.= ";\n";
    
    @mkdir(PLA_DATA, true, 0755);
    file_put_contents(PLA_DATA.$_GET['plugin_id'].'.php', $content);
  }
  else
  {
    $files = include(PLA_DATA.$_GET['plugin_id'].'.php');
  }
  
  $counts = array('ok'=>0,'missing'=>0,'useless'=>0);
  
  // get strings list
  $strings = analyze_files($_GET['plugin_id'], $files);
  
  // load language files
  $lang_common = load_language_file(PHPWG_ROOT_PATH.'language/en_UK/common.lang.php');
  $lang_admin = load_language_file(PHPWG_ROOT_PATH.'language/en_UK/admin.lang.php');
  
  $language_files = list_plugin_languages_files($_GET['plugin_id']);
  foreach ($language_files as $name => $path)
  {
    $lang_plugin[ $name ] = load_language_file(PHPWG_PLUGINS_PATH.$_GET['plugin_id'].$path);
  }
  
  // analyse
  foreach ($strings as $string => &$string_data)
  {
    // find where the string is defined
    $string_data['in_common'] = array_key_exists($string, $lang_common);
    $string_data['in_admin'] = array_key_exists($string, $lang_admin);
    $string_data['in_plugin'] = array();
    foreach ($language_files as $name => $path)
    {
      if (array_key_exists($string, $lang_plugin[$name])) $string_data['in_plugin'][] = $name;
    }
    
    // very rare case
    if (count($string_data['in_plugin'])>1)
    {
      $string_data['warnings'][] = l10n('This string is translated in multiple files');
    }
    
    $missing = $useless = $ok = false;
    $string_data['is_admin'] = true;
    
    // analyse for each file where the string exists
    foreach ($string_data['files'] as $file => &$file_data)
    {
      // the string is "admin" if all files are "admin"
      $string_data['is_admin'] &= $file_data['is_admin'];
      
      // find if the string is translated in one of the language files included in this file
      $exists = count(array_intersect($file_data['lang_files'], $string_data['in_plugin'])) > 0;
      
      // useless if translated in the plugin AND in common or admin
      if ($exists && ($string_data['in_common'] || ($file_data['is_admin'] && $string_data['in_admin'])))
      {
        $file_data['stat'] = 'useless';
        $useless = true;
      }
      // missing if not translated in the plugin NOR in common or admin
      else if (!$exists && !$string_data['in_common'] && (!$file_data['is_admin'] || !$string_data['in_admin']))
      {
        $file_data['stat'] = 'missing';
        $missing = true;
      }
      // else ok
      else
      {
        $file_data['stat'] = 'ok';
        $ok = true;
      }
    }
    unset($file_data);
    
    // string is missing if at least missing in one file
    if ($missing)
    {
      $string_data['stat'] = 'missing';
      $counts['missing']++;
    }
    // string is useless if useless in all files
    else if ($useless && !$ok)
    {
      $string_data['stat'] = 'useless';
      $counts['useless']++;
    }
    // else ok
    else
    {
      // another very rare case
      if ($useless)
      {
        $string_data['warnings'][] = l10n('This string is useless in some files');
      }
      
      $string_data['stat'] = 'ok';
      $counts['ok']++;
    }
  }
  unset($string_data);
  
  // unused strings
  $unused = array();
  foreach ($language_files as $name => $path)
  {
    $unused = array_merge($unused, array_diff_key($lang_plugin[ $name ], $strings));
  }
  
  foreach ($unused as $string => $translation)
  {
    $string_data = array(
      'files' => array(),
      'in_common' => array_key_exists($string, $lang_common),
      'in_admin' => array_key_exists($string, $lang_admin),
      'in_plugin' => array(),
      'stat' => 'useless',
      'is_admin' => false,
      'warning' => array(l10n('This string is not used anywhere in the plugin')),
      );
      
    foreach ($language_files as $name => $path)
    {
      if (array_key_exists($string, $lang_plugin[$name])) $string_data['in_plugin'][] = $name;
    }
    
    $strings[ $string ] = $string_data;
    $counts['useless']++;
  }
  
  uksort($strings, 'strnatcasecmp'); // natural sort
  $counts['total'] = array_sum($counts);
  
  $template->assign(array(
    'PLA_STEP' => 'analysis',
    'PLA_PLUGIN' => $plugins->fs_plugins[ $_GET['plugin_id'] ],
    'PLA_STRINGS' => $strings,
    'PLA_LANG_FILES' => array_keys($language_files),
    'PLA_COUNTS' => $counts,
    'U_BACK' => PLA_ADMIN.'&amp;plugin_id='.$_GET['plugin_id'].'&amp;config',
    'U_REFRESH' => PLA_ADMIN.'&amp;plugin_id='.$_GET['plugin_id'].'&amp;analyze',
    ));
}

// template vars
$template->assign(array(
  'PLA_PATH'=> PLA_PATH, 
  'PLA_ABS_PATH'=> realpath(PLA_PATH).'/', 
  'PLA_ADMIN' => PLA_ADMIN,
  ));

$template->set_filename('pla_content', realpath(PLA_PATH.'template/main.tpl'));
$template->assign_var_from_handle('ADMIN_CONTENT', 'pla_content');
