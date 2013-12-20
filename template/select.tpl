{footer_script}{literal}
$('form#pla').submit(function() {
  window.location.href = $(this).attr('action') + '&plugin_id=' + $(this).find('select').val();
  return false;
});
{/literal}{/footer_script}

<form method="GET" action="{$F_ACTION}" class="properties" id="pla">
<fieldset>
  <legend>{'Select a plugin'|translate}</legend>
  
  <select name="plugin_id">
  {foreach from=$PLA_PLUGINS item=plugin key=plugin_id}
    <option value="{$plugin_id}">{$plugin.name} ({$plugin.version})</option>
  {/foreach}
  </select>

  <p class="formButtons"><input type="submit" value="{'Continue'|translate}"></p>
</fieldset>

<fieldset>
  <legend>{'How to use?'|translate}</legend>

  <p>
    This tool analyses each file of the selected plugin, searching for <b>l10n</b>, <b>l10n_dec</b> and <b>translate</b> functions.<br>
    Then it compares the matched strings to the content of the plugin's language files and the common and admin core language files.<br>
    Each file of the plugin can be configured as <b>Common</b> (public) or <b>Admin</b> and can be attached to one or more plugin's language files.<br>
    <br>
    When the analysis is complete, each string can have one of these three status :
  </p>
  
  <dl style="margin-left:30px;">
    <dt class="iconpla-attention">missing :</dt>
    <dd>
      not in the plugin language file<br>
      <b>AND</b> not in the common language file<br>
      <b>AND</b> (<br>
      &nbsp;&nbsp;&nbsp;&nbsp;belonging to at least one common file<br>
      &nbsp;&nbsp;&nbsp;&nbsp;<b>OR</b> not in the admin language file<br>
      )
    </dd>
  
    <dt class="iconpla-attention-circled">useless :</dt>
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
  
    <dt class="iconpla-ok-squared">ok :</dt>
    <dd>
      any other case
    </dd>
  </dl>
  
  <p>
    You can click the <span class="iconpla-plus-circled"></span> icon on the left of each string to see in which files it is used. Additionally you can see if the string is missing in only one or all files (corresponding to a problem in the loaded language files.
  </p>
</fieldset>

<fieldset>
  <legend>{'Limitations'|translate}</legend>
  
  <p>
    For both core and plugin dependencies, we assume that the language files are loaded at the beginning of the file and available for the whole file. In practice this is not true because of functions, triggers, pre-filters, etc.
  </p>
</fieldset>
</form>