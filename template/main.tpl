{combine_css path=$PLA_PATH|@cat:"template/style.css"}
{combine_css path=$PLA_PATH|@cat:"template/fontello/css/fontello_pla.css"}


<div class="titrePage">
	<h2>Plugin Language Analysis</h2>
</div>

{if isset($U_BACK)}
<p style="text-align:left;margin-left:20px;"><a href="{$U_BACK}" class="buttonLike">{'Back'|@translate}</a></p>
{/if}


{* <!-- select --> *}
{if $PLA_STEP=='select'}
{footer_script}{literal}
$('form#pla').submit(function() {
  window.location.href = location.href + '&plugin_id=' + $(this).find('select').val();
  return false;
});
{/literal}{/footer_script}

<form method="GET" action="{$F_ACTION}" class="properties" id="pla">
<fieldset>
  <legend>{'How to use?'|@translate}</legend>

  <p>
    This tool analyzes each file of the selected plugin, searching for <b>l10n</b>, <b>l10n_dec</b> and <b>translate</b> functions.<br>
    Then it compares the matched strings to the content of the plugin language file and the common and admin core language files.<br>
    Each file of the plugin can be configured as <b>Common</b> (public) or <b>Admin</b>.<br>
    <br>
    When the analysis is complete, each string can have one of these three status :
  </p>
  
  <dl style="margin-left:30px;">
    <dt class="iconpla-attention">missing</dt>
    <dd>
      not in the plugin language file<br>
      <b>AND</b> not in the common language file<br>
      <b>AND</b> (<br>
      &nbsp;&nbsp;&nbsp;&nbsp;belonging to at least one common file<br>
      &nbsp;&nbsp;&nbsp;&nbsp;<b>OR</b> not in the admin language file<br>
      )
    </dd>
  
    <dt class="iconpla-attention-circled">useless</dt>
    <dd>
      in the plugin language file<br>
      <b>AND</b> (<br>
      &nbsp;&nbsp;&nbsp;&nbsp;in the common language file<br>
      &nbsp;&nbsp;&nbsp;&nbsp;<b>OR</b> (<br>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;not belonging to any common file<br>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>AND</b> in the admin language file<br>
      &nbsp;&nbsp;&nbsp;&nbsp;)<br>
      )
    </dd>
  
    <dt class="iconpla-ok-squared">ok</dt>
    <dd>
      any other case
    </dd>
  </dl>
  
  <p>
    You can click the <span class="iconpla-plus-circled"></span> icon on the left of each string to see where it is located.
  </p>
</fieldset>

<fieldset>
  <legend>{'Select a plugin'|@translate}</legend>
  
  <select name="plugin_id">
  {foreach from=$PLA_PLUGINS item=plugin key=plugin_id}
    <option value="{$plugin_id}">{$plugin.name} ({$plugin.version})</option>
  {/foreach}
  </select>

  <p class="formButtons"><input type="submit" value="{'Continue'|@translate}"></p>
</fieldset>
</form>

{* <!-- configure --> *}
{elseif $PLA_STEP=='config'}
{footer_script}{literal}
$('.switch-button.type span').click(function() {
  $(this).siblings('span').removeClass('active');
  $(this).addClass('active');
  
  if ($(this).hasClass('common')) {
    $(this).nextAll('input').val('false');
  }
  else {
    $(this).nextAll('input').val('true');
  }
});
$('.switch-button.other span').click(function() {
  if ($(this).hasClass('active')) {
    $(this).removeClass('active');
    $(this).next('input').val('false');
  }
  else {
    $(this).addClass('active');
    $(this).next('input').val('true');
  }
});
{/literal}{/footer_script}

<form method="POST" action="{$F_ACTION}" class="properties">
<fieldset>
  <legend>{'Select dependencies'|@translate}</legend>
  
  <table class="files">
  <thead>
    <tr>
      <th></th>
      <th>{'Core dependency'|@translate}</th>
      <th>{'Local dependencies'|@translate}</th>
    </tr>
  </thead>
  
  <tbody>
  {foreach from=$PLA_FILES item=file}
    <tr>
      <td>{$file.path}</td>
      <td>
        <div class="switch-button type">
          <span class="item common {if not $file.is_admin}active{/if}">{'Common'|@translate}</span>
          <span class="item admin {if $file.is_admin}active{/if}">{'Admin'|@translate}</span>
          <input type="hidden" name="files[{$file.path}][is_admin]" value="{if $file.is_admin}true{else}false{/if}">
        </div>
      </td>
      <td>
        <div class="switch-button other">
        {foreach from=$PLA_LANG_FILES item=path key=lang_file}
          <span class="item other {if $lang_file|in_array:$file.lang_files}active{/if}">{$lang_file}</span>
          <input type="hidden" name="files[{$file.path}][lang_files][{$lang_file}]" value="{if $lang_file|in_array:$file.lang_files}true{else}false{/if}">
        {/foreach}
        </div>
      </td>
    </tr>
  {/foreach}
  </tbody>
  </table>
  
  <p class="formButtons"><input type="submit" value="{'Continue'|@translate}"></p>
</fieldset>
</form>

{* <!-- analysis --> *}
{elseif $PLA_STEP=='analysis'}
{footer_script}{literal}
$('.strings tr.string td.toggler').click(function() {
  if ($(this).hasClass('iconpla-plus-circled')) {
    $(this).removeClass('iconpla-plus-circled').addClass('iconpla-minus-circled');
    $(this).parent().nextUntil('tr.string').show();
  }
  else {
    $(this).removeClass('iconpla-minus-circled').addClass('iconpla-plus-circled');
    $(this).parent().nextUntil('tr.string').hide();
  }
});

$('.strings tr.string').hover(
  function() {
    $(this).addClass('hover').nextUntil('tr.string').addClass('hover');
  },
  function() {
    $(this).removeClass('hover').nextUntil('tr.string').removeClass('hover');
  }
);
$('.strings tr.file').hover(
  function() {
    $(this).prevAll('tr.string:first').addClass('hover').nextUntil('tr.string').addClass('hover');
  },
  function() {
    $(this).prevAll('tr.string:first').removeClass('hover').nextUntil('tr.string').removeClass('hover');
  }
);

$('.open-all').click(function() {
  $('.strings tr.file').show();
});
$('.open-missing').click(function() {
  $('.strings tr.file.string-missing').show();
});
$('.close-all').click(function() {
  $('.strings tr.file').hide();
});
{/literal}{/footer_script}

{html_style}
.strings tr td:nth-last-child(-n+{math equation="2+x" x=$PLA_LANG_FILES|@count}) {ldelim}
  text-align:center;
}
{/html_style}

<fieldset>
  <legend>{$PLA_PLUGIN.name}</legend>
  
  <p style="text-align:left;">
    <a class="open-all">{'Expand all'|@translate}</a>
    / <a class="open-missing">{'Expand missing'|@translate}</a>
    / <a class="close-all">{'Collapse all'|@translate}</a>
  </p>
  
  <table class="strings">
  <thead>
    <tr>
      <th></th>
      <th class="legend">
        <span class="missing">{'Missing'|@translate}</span>
        <span class="useless">{'Useless'|@translate}</span>
      </th>
      <th>{'Dependency'|@translate}</th>
    {foreach from=$PLA_LANG_FILES item=path key=lang_file}
      <th>{$lang_file}</th>
    {/foreach}
      <th>common.lang</th>
      <th>admin.lang</th>
    </tr>
  </thead>
    
  <tbody>
  {foreach from=$PLA_STRINGS item=data key=string}
    <!-- begin string -->
    <tr class="string {$data.stat}">
      <td class="toggler iconpla-plus-circled"></td>
      <td>{$string|htmlspecialchars}</td>
      {if $data.is_admin}<td class="text-admin">{'Admin'|@translate}</td>
      {else}<td class="text-common">{'Common'|@translate}</td>{/if}
    {foreach from=$PLA_LANG_FILES item=path key=lang_file}
      <td>{if $lang_file|in_array:$data.in_plugin}<b>{'Yes'|@translate}</b>{else}{'No'|@translate}{/if}</td>
    {/foreach}
      <td>{if $data.in_common}<b>{'Yes'|@translate}</b>{else}{'No'|@translate}{/if}</td>
      <td>{if $data.in_admin}<b>{'Yes'|@translate}</b>{else}{'No'|@translate}{/if}</td>
    </tr>
    {foreach from=$data.files item=file_data key=file}
      <!-- begin file -->
      <tr class="file string-{$data.stat} {$file_data.stat}">
        <td></td>
        <td>{$file} <i>({', '|@implode:$file_data.lines})</i></td>
        {if $file_data.is_admin}<td class="text-admin">{'Admin'|@translate}</td>
        {else}<td class="text-common">{'Common'|@translate}</td>{/if}
      {foreach from=$PLA_LANG_FILES item=path key=lang_file}
        <td>{if $lang_file|in_array:$file_data.lang_files}<b>{'Yes'|@translate}</b>{else}{'No'|@translate}{/if}</td>
      {/foreach}
        <td></td>
        <td></td>
      </tr>
    {/foreach} {* <!-- end file --> *}
  {/foreach} {* <!-- end string --> *}
  </tbody>
  
  <tfoot>
    <tr>
      <th></th>
      <th>{'%d strings : %d missing and %d useless.'|@translate|sprintf:$PLA_COUNTS.total:$PLA_COUNTS.missing:$PLA_COUNTS.useless}</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </tfoot>
  </table>
</fieldset>

{/if}