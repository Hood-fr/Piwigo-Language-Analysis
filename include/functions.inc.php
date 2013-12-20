<?php
defined('PLA_PATH') or die('Hacking attempt!');

/**
 * list files of a plugin
 * @param: string $id, plugin id
 * @return: array of paths relative to plugin root
 */
function list_plugin_files($id, $path=null)
{
  if (empty($path))
  {
    $path = '/';
  }
  
  if ($path == '/language/')
  {
    return array();
  }
  
  if (strlen($path)-strrpos($path, '_data/') == 6)
  {
    return array();
  }
  
  if (($handle = @opendir(PHPWG_PLUGINS_PATH.$id.$path)) === false)
  {
    return array();
  }
  
  $data = array();
  
  while ($entry = readdir($handle))
  {
    if ($entry=='.' || $entry=='..' || $entry=='.svn' || $entry=='index.php') continue;
    
    if (is_dir(PHPWG_PLUGINS_PATH.$id.$path.$entry))
    {
      $data = array_merge($data, list_plugin_files($id, $path.$entry.'/'));
    }
    else
    {
      $ext = strtolower(get_extension($entry));
      if (in_array($ext, array('php', 'tpl')))
      {
        $data[] = $path.$entry;
      }
    }
  }
  
  closedir($handle);
  
  return $data;
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
      $ext = strtolower(get_extension($entry));
      if ($ext == 'php')
      {
        $data[ basename($entry, '.php') ] = $path.$entry;
      }
    }
  }
  
  closedir($handle);
  
  return $data;
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
    if (preg_match_all('#l10n\((?:\s*)(?:["\']{1})(.*?)(?:["\']{1})#', $line, $matches))
    {
      for ($j=0; $j<count($matches[1]); ++$j)
      {
        $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
      }
    }
    // translate
    if (preg_match_all('#\{(?:\\\\{0,1})(?:["\']{1})(.*?)(?:\\\\{0,1})(?:["\']{1})\|(?:@{0,1})translate#', $line, $matches))
    {
      for ($j=0; $j<count($matches[1]); ++$j)
      {
        $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
      }
    }
    // translate_dec
    if (preg_match_all('#translate_dec:(?:\\\\{0,1})(?:["\']{1})(.*?)(?:\\\\{0,1})(?:["\']{1}):(?:\\\\{0,1})(?:["\']{1})(.*?)(?:\\\\{0,1})(?:["\']{1})}#', $line, $matches))
    {
      for ($j=0; $j<count($matches[1]); ++$j)
      {
        $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
        $strings[ stripslashes($matches[2][$j]) ][] = $i+1;
      }
    }
    // l10n_dec on one line
    if (preg_match_all('#l10n_dec\((?:\s*)(?:["\']{1})(.*?)(?:["\']{1})(?:\s*),(?:\s*)(?:["\']{1})(.*?)(?:["\']{1})#', $line, $matches))
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
      
      if (preg_match_all('#l10n_dec\((?:\s*)(?:["\']{1})(.*?)(?:["\']{1})(?:\s*),(?:\s*)(?:["\']{1})(.*?)(?:["\']{1})#', $three_lines, $matches))
      {
        for ($j=0; $j<count($matches[1]); ++$j)
        {
          $strings[ stripslashes($matches[1][$j]) ][] = $i+1;
          $strings[ stripslashes($matches[2][$j]) ][] = $i+1;
        }
      }
    }
    // l10n_args
    if (preg_match_all('#get_l10n_args\((?:\s*)(?:["\']{1})(.*?)(?:["\']{1})#', $line, $matches))
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
  
  if (preg_match_all('#load_language\((?:\s*)(?:["\']{1})(.*?)(?:["\']{1})#', $content, $matches))
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

?>