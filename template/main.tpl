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
    You can click the <span class="icon-plus-circled"></span> icon on the left of each string to see where it is located.
  </p>
</fieldset>

<fieldset>
  <legend>{'Select a plugin'|@translate}</legend>
  
  <select name="plugin_id">
  {foreach from=$PLA_PLUGINS item=plugin}
    <option value="{$plugin.id}">{$plugin.id} ({$plugin.version})</option>
  {/foreach}
  </select>

  <p class="formButtons"><input type="submit" value="{'Continue'|@translate}"></p>
</fieldset>
</form>

{* <!-- configure --> *}
{elseif $PLA_STEP=='config'}
{footer_script}{literal}
$('.type-button span').click(function() {
  $(this).siblings('span').removeClass('active');
  $(this).addClass('active');
  
  if ($(this).hasClass('common')) {
    $(this).nextAll('input').val('false');
  }
  else {
    $(this).nextAll('input').val('true');
  }
});
{/literal}{/footer_script}

<form method="POST" action="{$F_ACTION}" class="properties">
<fieldset>
  <legend>{'Select dependencies'|@translate}</legend>
  
  <b>{'Plugin language file name'|@translate}</b>
  <input type="test" name="filename" value="{$PLA_FILENAME}">
  <br><br>
  
  {foreach from=$PLA_FILES item=file}
    <div class="type-button">
      <span class="item common {if not $file.is_admin}active{/if}">{'Common'|@translate}</span><!--
      --><span class="item admin {if $file.is_admin}active{/if}">{'Admin'|@translate}</span>
      <input type="hidden" name="files[{$file.path}]" value="{if $file.is_admin}true{else}false{/if}">
    </div>
    {$file.path}<br>
  {/foreach}
  
  <p class="formButtons"><input type="submit" value="{'Continue'|@translate}"></p>
</fieldset>
</form>

{* <!-- analysis --> *}
{elseif $PLA_STEP=='analysis'}
{footer_script}{literal}
$('.strings tr td:first-child').click(function() {
  if ($(this).hasClass('icon-plus-circled')) {
    $(this).removeClass('icon-plus-circled').addClass('iconpla-minus-circled');
    $(this).next().children('ul').show();
  }
  else {
    $(this).removeClass('iconpla-minus-circled').addClass('icon-plus-circled');
    $(this).next().children('ul').hide();
  }
});
{/literal}{/footer_script}

<fieldset>
  <legend>{$PLA_PLUGIN}</legend>
  
  <table class="strings">
  <thead>
    <tr>
      <th></th>
      <th class="legend">
        <span class="missing">{'Missing'|@translate}</span>
        <span class="useless">{'Useless'|@translate}</span>
      </th>
      <th>{'Dependency'|@translate}</th>
      <th>{'In plugin'|@translate}</th>
      <th>{'In common'|@translate}</th>
      <th>{'In admin'|@translate}</th>
    </tr>
  </thead>
    
  <tbody>
  {foreach from=$PLA_STRINGS item=data key=string}
    <tr class="string {$data.stat}">
      <td class="icon-plus-circled"></td>
      <td>
        {$string|htmlspecialchars}
        <ul>
        {foreach from=$data.files item=lines key=file}
          <li class="text-{if $PLA_FILES[$file].is_admin}admin{else}common{/if}">
            {$file} <i>({', '|@implode:$lines})</i></li>
        {/foreach}
        </ul>
      </td>
      {if $data.is_admin}<td class="text-admin">{'Admin'|@translate}</td>
      {else}<td class="text-common">{'Common'|@translate}</td>{/if}
      <td>{if $data.in_plugin}<b>{'Yes'|@translate}</b>{else}{'No'|@translate}{/if}</td>
      <td>{if $data.in_common}<b>{'Yes'|@translate}</b>{else}{'No'|@translate}{/if}</td>
      <td>{if $data.in_admin}<b>{'Yes'|@translate}</b>{else}{'No'|@translate}{/if}</td>
    </tr>
  {/foreach}
  </tbody>
  
  <tfoot>
    <tr>
      <th></th>
      <th>{'%d strings : %d missing and %d useless.'|@translate|sprintf:$PLA_COUNTS.total:$PLA_COUNTS.missing:$PLA_COUNTS.useless}</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </tfoot>
  </table>
</fieldset>

{/if}