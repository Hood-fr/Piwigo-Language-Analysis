<?php 
/*
Plugin Name: Language Analysis
Version: auto
Description: Add a tool to analyse translation strings of plugins
Plugin URI: auto
Author: Mistic
Author URI: http://www.strangeplanet.fr
*/

defined('PHPWG_ROOT_PATH') or die('Hacking attempt!');

if (!defined('IN_ADMIN'))
{
  return;
}

if (basename(dirname(__FILE__)) != 'plugin_lang_analysis')
{
  add_event_handler('init', 'pla_error');
  function pla_error()
  {
    global $page;
    $page['errors'][] = 'Language Analysis folder name is incorrect, uninstall the plugin and rename it to "plugin_lang_analysis"';
  }
  return;
}

global $conf;

define('PLA_PATH' , PHPWG_PLUGINS_PATH . 'plugin_lang_analysis/');
define('PLA_ADMIN', get_root_url() . 'admin.php?page=plugin-plugin_lang_analysis');
define('PLA_DATA',  $conf['data_location'] . 'plugin_lang_analysis/');

add_event_handler('loc_begin_admin', 'pla_begin_admin');

function pla_begin_admin()
{
  global $template;
  $template->set_prefilter('admin', 'pla_add_menu_item');
}

function pla_add_menu_item($content)
{
  $search = '{\'Updates\'|@translate}</a></li>';
  $add = '<li><a class="icon-language" href="'.PLA_ADMIN.'">Language Analysis</a></li>';
  return str_replace($search, $search."\n".$add, $content);
}
