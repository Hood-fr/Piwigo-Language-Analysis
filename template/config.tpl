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
        {foreach from=$PLA_LANG_FILES item=lang_file}
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