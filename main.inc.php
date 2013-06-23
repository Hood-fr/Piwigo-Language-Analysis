<?php 
/*
Plugin Name: Plugin Language Analysis
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

global $conf;

defined('PLA_ID') or define('PLA_ID', basename(dirname(__FILE__)));
define('PLA_PATH' , PHPWG_PLUGINS_PATH . PLA_ID . '/');
define('PLA_ADMIN', get_root_url() . 'admin.php?page=plugin-' . PLA_ID);
define('PLA_DATA',  $conf['data_location'] . PLA_ID . '/');

add_event_handler('loc_begin_admin', 'pla_begin_admin');

function pla_begin_admin()
{
  global $template;
  $template->set_prefilter('admin', 'pla_add_menu_item');
}

function pla_add_menu_item($content, &$smarty)
{
  $search = 'href="{$U_UPDATES}">{\'Updates\'|@translate}</a></li>';
  $add = '<li><a class="icon-language" href="'.PLA_ADMIN.'">Plugin Language Analysis</a></li>';
  return str_replace($search, $search."\n".$add, $content);
}

?>