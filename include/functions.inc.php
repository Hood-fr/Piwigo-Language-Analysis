<?php
defined('PLA_PATH') or die('Hacking attempt!');

/**
 * List files of a plugin
 * @param string $id, plugin id
 * @return nested array of paths relative to plugin root
 *    Keys are numeric for files or directory name
 *    Values are file name or array of more entries
 */
function list_plugin_files($id, $path=null)
{
  if (empty($path))
  {
    $path = '/';
  }
  
  if ($path == '/language/')
  {
    return null;
  }
  
  if (strlen($path)-strrpos($path, '_data/') == 6)
  {
    return null;
  }
  
  if (($handle = @opendir(PHPWG_PLUGINS_PATH.$id.$path)) === false)
  {
    return null;
  }
  
  $data = array();
  
  while ($entry = readdir($handle))
  {
    if ($entry=='.' || $entry=='..' || $entry=='.svn' || $entry=='index.php') continue;
    
    if (is_dir(PHPWG_PLUGINS_PATH.$id.$path.$entry))
    {
      $data[$entry.'/'] = list_plugin_files($id, $path.$entry.'/');
    }
    else
    {
      $ext = strtolower(get_extension($entry));
      if (in_array($ext, array('php', 'tpl')))
      {
        $data[] = $entry;
      }
    }
  }
  
  closedir($handle);
  
  uksort($data, 'custom_folder_sort');
  
  return array_filter($data);
}

/**
 * Merges the result of *list_plugin_files* and data from cache
 * Needs the result of *list_plugin_languages_files* and *get_loaded_in_main* in global scope
 * 
 * @param array &$files
 * @param array $saved_files
 * @return nested array of files with metadata
 *    Keys are numeric for files or directory name
 *    Values are file metadata (filename, is_admin, ignore, lang_files) or array of more entries
 */
function populate_plugin_files(&$files, $saved_files, $root='/', $is_admin=false)
{
  global $language_files, $default_lang_files;
  
  foreach ($files as $id => &$file)
  {
    if (is_array($file))
    {
      populate_plugin_files($file,
        isset($saved_files[$id]) ? $saved_files[$id] : array(),
        $root.$id,
        strpos($id, 'admin') !== false || $is_admin
        );
    }
    else if (isset($saved_files[ $file ]))
    {
      $id = $file;
      $file = $saved_files[ $id ];
      $file['filename'] = $id;
      $file['lang_files'] = array_intersect($file['lang_files'], array_keys($language_files));
    }
    else
    {
      $id = $file;
      $file = array(
        'filename' => $id,
        'is_admin' => strpos($id, 'admin') !== false || $is_admin,
        'ignore' => false,
        'lang_files' => $default_lang_files,
        );
    }
  }
  unset($file);
}

/**
 * Sanitize the result of config form for direct usage and cache
 * @param array &$files
 * @return nested array of files with metadata
 *    Keys are file name or directory name
 *    Values are file metadata (is_admin, ignore, lang_files) or array of more entries 
 */
function clean_files_from_config(&$files)
{
  foreach ($files as $id => &$file)
  {
    if (!isset($file['ignore']))
    {
      clean_files_from_config($file);
    }
    // security against max_input_vars overflow
    else if (isset($file['is_admin']) && isset($file['ignore']) && isset($file['lang_files']))
    {
      $file['is_admin'] = get_boolean($file['is_admin']);
      $file['ignore'] = get_boolean($file['ignore']);
      $file['lang_files'] = array_keys(array_filter($file['lang_files'], 'get_boolean'));
    }
  }
  unset($file);
}

/**
 * Custom sort callback for files and directories
 * Alphabetic order with files before directories
 */
function custom_folder_sort($a, $b)
{
  if (is_int($a) && is_int($b))
  {
    return $a-$b;
  }
  else if (is_string($a) && is_string($b))
  {
    return strnatcasecmp($a, $b);
  }
  else if (is_string($a) && is_int($b))
  {
    return 1;
  }
  else
  {
    return -1;
  }
}

/**
 * list language files of a plugin
 * @param: string $id, plugin id
 * @return: array, keys are basenames, values are paths relative to plugin root
 */
function list_plugin_languages_files($id)
{
  $path = '/language/en_UK/';
  
  if (($handle = @opendir(PHPWG_PLUGINS_PATH.$id.$path)) === false)
  {
    return array();
  }
  
  $data = array();
  
  while ($entry = readdir($handle))
  {
    if ($entry=='.' || $entry=='..' || $entry=='.svn' || $entry=='index.php') continue;
    
    if (!is_dir(PHPWG_PLUGINS_PATH.$id.$path.$entry))
    {
      if (get_extension($entry) == 'php')
      {
        $data[ basename($entry, '.php') ] = $path.$entry;
      }
    }
  }
  
  closedir($handle);
  
  return $data;
}

/**
 * Construct the list of all used strings in the plugin files
 * @param string $plugin
 * @param array $files
 * @return array multidimensional
 */
function analyze_files($plugin, $files, &$strings = array(), $path='')
{
  foreach ($files as $id => $file)
  {
    if (!isset($file['ignore']))
    {
      analyze_files($plugin, $file, $strings, $path.$id);
    }
    else
    {
      if ($file['ignore']) continue;

      $file_strings = analyze_file($plugin.'/'.$path.$id);
      
      foreach ($file_strings as $string => $lines)
      {
        $strings[ $string ]['files'][ $path.$id ] = $file + array('lines' => $lines);
      }
    }
  }
  
  return $strings;
}

/**
 * list translated strings of a file
 * @param: string $path, file $path relative to main plugins folder
 * @return: array, keys are language strings, values are arrays of lines
 */
function analyze_file($path)
{
  $lines = file(PHPWG_PLUGINS_PATH.$path, FILE_IGNORE_NEW_LINES);
  
  $strings = array();
  
  foreach ($lines as $i => $line)
  {
    // l10n
    if (preg_match_all('#l10n\\(\s*["\']{1}(.*?)["\']{1}\s*[,)]{1}#', $line, $matches))
    {
      for ($j=0; $j<count($matches[1]); ++$j)
      {
        $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
      }
    }
    // translate
    if (preg_match_all('#\\{\\\\?["\']{1}(.*?)\\\\?["\']{1}\\|@?translate#', $line, $matches))
    {
      for ($j=0; $j<count($matches[1]); ++$j)
      {
        $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
      }
    }
    // translate_dec
    if (preg_match_all('#translate_dec:\\\\?["\']{1}(.*?)\\\\?["\']{1}:\\\\?["\']{1}(.*?)\\\\?["\']{1}}#', $line, $matches))
    {
      for ($j=0; $j<count($matches[1]); ++$j)
      {
        $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
        $strings[ stripslashes($matches[2][$j]) ][] = $i+1;
      }
    }
    // l10n_dec on one line
    if (preg_match_all('#l10n_dec\\(\s*["\']{1}(.*?)["\']{1}\s*,\s*["\']{1}(.*?)["\']{1}#', $line, $matches))
    {
      for ($j=0; $j<count($matches[1]); ++$j)
      {
        $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
        $strings[ stripslashes($matches[2][$j]) ][] = $i+1;
      }
    }
    // l10n_dec on two or three lines
    else if (strpos($line, 'l10n_dec')!==false)
    {
      $three_lines = $lines[$i];
      if (isset($lines[$i+1]))
      {
        $three_lines.= ' '.$lines[$i+1];
        if (isset($lines[$i+2])) $three_lines.= ' '.$lines[$i+2];
      }
      
      if (preg_match_all('#l10n_dec\\(\s*["\']{1}(.*?)["\']{1}\s*,\s*["\']{1}(.*?)["\']{1}#', $three_lines, $matches))
      {
        for ($j=0; $j<count($matches[1]); ++$j)
        {
          $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
          $strings[ stripslashes($matches[2][$j]) ][] = $i+1;
        }
      }
    }
    // l10n_args
    if (preg_match_all('#get_l10n_args\\(\s*["\']{1}(.*?)["\']{1}\s*[,)]{1}#', $line, $matches))
    {
      for ($j=0; $j<count($matches[1]); ++$j)
      {
        $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
      }
    }
  }
  
  return $strings;
}

/**
 * get language files loaded in main.inc.php
 * @param: string $id, plugin id
 * @return: array of file basenames
 */
function get_loaded_in_main($id)
{
  $content = file_get_contents(PHPWG_PLUGINS_PATH.$id.'/main.inc.php');
  
  $files = array();
  
  if (preg_match_all('#load_language\\(\s*["\']{1}(.*?)["\']{1}#', $content, $matches))
  {
    $files = $matches[1];
  }
  
  return $files;
}

/**
 * load a language file
 */
function load_language_file($path)
{
  @include($path);
  if (!isset($lang)) return array();
  return $lang;
}