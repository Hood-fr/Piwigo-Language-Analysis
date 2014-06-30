<div class="files level-{$level}">
  <table>
  {if $level==0}
    <thead>
      <tr>
        <th class=filename></th>
        <th class=ignore>{'Ignore'|translate}</th>
        <th class=type>{'Core dependency'|translate}</th>
        <th class=other>{'Local dependencies'|translate}</th>
      </tr>
    </thead>
  {/if}

    <tbody>
    {foreach from=$files item=file key=id}
      {if !isset($file.ignore)}
        <tr class=folder>
          <td class=filename>
            <i class="icon-folder-open"></i>
            {$id}
          </td>
          <td class=ignore>
            <div class="switch-button ignore">
              <span class="item ignore" data-val="ignore">&times;</span>
            </div>
          </td>
          <td class=type>
            <div class="switch-button type">
              <span class="item common" data-val="common">{'Common'|translate}</span>
              <span class="item admin" data-val="admin">{'Admin'|translate}</span>
            </div>
          </td>
          <td class=other>
            <div class="switch-button other">
            {foreach from=$PLA_LANG_FILES item=lang_file}
              <span class="item other" data-val="{$lang_file}">{$lang_file}</span>
            {/foreach}
            </div>
          </td>
        </tr>
        <tr class=nested>
          <td colspan=4>
            {include file=$PLA_ABS_PATH|cat:'template/config_list.inc.tpl' files=$file level=$level+1 path=$path|cat:"[`$id`]"}
          </td>
        </tr>
      {else}
        <tr>
          <td class=filename>
            <i class="iconpla-doc-text-inv"></i>
            {$file.filename}
          </td>
          <td class=ignore>
            <div class="switch-button ignore">
              <span class="item ignore {if $file.ignore}active{/if}" data-val="ignore">&times;</span>
              <input type="hidden" name="files{$path}[{$file.filename}][ignore]" value="{if $file.ignore}true{else}false{/if}">
            </div>
          </td>
          <td class=type>
            <div class="switch-button type">
              <span class="item common {if not $file.is_admin}active{/if}" data-val="common">{'Common'|translate}</span>
              <span class="item admin {if $file.is_admin}active{/if}" data-val="admin">{'Admin'|translate}</span>
              <input type="hidden" name="files{$path}[{$file.filename}][is_admin]" value="{if $file.is_admin}true{else}false{/if}">
            </div>
          </td>
          <td class=other>
            <div class="switch-button other">
            {foreach from=$PLA_LANG_FILES item=lang_file}
              <span class="item other {if $lang_file|in_array:$file.lang_files}active{/if}" data-val="{$lang_file}">{$lang_file}</span>
              <input type="hidden" name="files{$path}[{$file.filename}][lang_files][{$lang_file}]" value="{if $lang_file|in_array:$file.lang_files}true{else}false{/if}">
            {/foreach}
            </div>
          </td>
        </tr>
      {/if}
    {/foreach}
    </tbody>
  </table>
</div>