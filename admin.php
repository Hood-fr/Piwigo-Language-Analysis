<?php
defined('PLA_PATH') or die('Hacking attempt!');
 
global $template, $page;

$page['active_menu'] = get_active_menu('updates');

include_once(PLA_PATH . 'include/functions.inc.php');


/* PLUGINS LIST */
if (!isset($_GET['plugin_id']))
{
  $query = '
SELECT *
  FROM '.PLUGINS_TABLE.'
  ORDER BY LOWER(id)
;';

  $plugins = hash_from_query($query, 'id');

  $template->assign(array(
    'PLA_STEP' => 'select',
    'PLA_PLUGINS' => $plugins,
    'F_ACTION' => PLA_ADMIN,
    ));
}

/* FILES LIST */
else if (!isset($_GET['analyze']))
{
  $files = list_plugin_files($_GET['plugin_id']);
  
  if (file_exists(PLA_PATH.'_data/'.$_GET['plugin_id'].'.php'))
  {
    list($filename, $saved_files) = @include(PLA_PATH.'_data/'.$_GET['plugin_id'].'.php');
  }
  else
  {
    $saved_files = array();
    $filename = 'plugin.lang.php';
  }
  
  foreach ($files as &$file)
  {
    if (isset($saved_files[$file]))
    {
      $file = $saved_files[$file];
    }
    else
    {
      $file = array(
        'path' => $file,
        'is_admin' => strpos($file, '/admin') === 0,
        );
    }
  }
  unset($file);
  
  $template->assign(array(
    'PLA_STEP' => 'config',
    'PLA_PLUGIN' => $_GET['plugin_id'],
    'PLA_FILES' => $files,
    'PLA_FILENAME' => $filename,
    'F_ACTION' => PLA_ADMIN.'&amp;plugin_id='.$_GET['plugin_id'].'&amp;analyze',
    'U_BACK' => PLA_ADMIN,
    ));
}
else
{
  // save
  if (isset($_POST['files']))
  {
    $filename = $_POST['filename'];
    
    $files = array();
    foreach ($_POST['files'] as $file => $is_admin)
    {
      $files[$file] = array(
        'path' => $file,
        'is_admin' => $is_admin=='true',
        );
    }
    
    $content = "<?php\nreturn ";
    $content.= var_export(array($filename, $files), true);
    $content.= ";\n?>";
    
    @mkdir(PLA_PATH.'_data/', true, 0755);
    file_put_contents(PLA_PATH.'_data/'.$_GET['plugin_id'].'.php', $content);
  }
  else
  {
    list($filename, $files) = include(PLA_PATH.'_data/'.$_GET['plugin_id'].'.php');
  }
  
  
  $strings = array();
  $counts = array('ok'=>0,'missing'=>0,'useless'=>0);
  
  // get strings list
  foreach ($files as $file => $file_data)
  {
    $file_strings = analyze_file($_GET['plugin_id'].$file);
    
    foreach ($file_strings as $string => $lines)
    {
      if (empty($strings[ $string ]))
        $strings[ $string ]['is_admin'] = $file_data['is_admin'];
      else
        $strings[ $string ]['is_admin'] = $strings[ $string ]['is_admin'] && $file_data['is_admin'];
      
      $strings[ $string ]['files'][ $file ] = $lines;
    }
  }
  
  // load language files
  $lang_common = load_language_file(PHPWG_ROOT_PATH.'language/en_UK/common.lang.php');
  $lang_admin = load_language_file(PHPWG_ROOT_PATH.'language/en_UK/admin.lang.php');
  $lang_plugin = load_language_file(PHPWG_PLUGINS_PATH.$_GET['plugin_id'].'/language/en_UK/'.$filename);
  
  // analyze
  foreach ($strings as $string => &$string_data)
  {
    $string_data['in_common'] = array_key_exists($string, $lang_common);
    $string_data['in_admin'] = array_key_exists($string, $lang_admin);
    $string_data['in_plugin'] = array_key_exists($string, $lang_plugin);
    
    if ($string_data['in_plugin'] && ($string_data['in_common'] || ($string_data['is_admin'] && $string_data['in_admin'])))
    {
      $string_data['stat'] = 'useless';
      $counts['useless']++;
    }
    else if (!$string_data['in_plugin'] && !$string_data['in_common'] && (!$string_data['is_admin'] || !$string_data['in_admin']))
    {
      $string_data['stat'] = 'missing';
      $counts['missing']++;
    }
    else
    {
      $string_data['stat'] = 'ok';
      $counts['ok']++;
    }
  }
  unset($string_data);
  
  uksort($strings, 'strnatcasecmp');
  $counts['total'] = array_sum($counts);
  
  $template->assign(array(
    'PLA_STEP' => 'analysis',
    'PLA_PLUGIN' => $_GET['plugin_id'],
    'PLA_FILES' => $files,
    'PLA_STRINGS' => $strings,
    'PLA_COUNTS' => $counts,
    'U_BACK' => PLA_ADMIN.'&amp;plugin_id='.$_GET['plugin_id'],
    ));
}

// template vars
$template->assign(array(
  'PLA_PATH'=> PLA_PATH, 
  'PLA_ABS_PATH'=> realpath(PLA_PATH), 
  'PLA_ADMIN' => PLA_ADMIN,
  ));

$template->set_filename('pla_content', realpath(PLA_PATH.'template/main.tpl'));
$template->assign_var_from_handle('ADMIN_CONTENT', 'pla_content');

?>