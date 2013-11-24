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
  $('.strings tr.string td.toggler').removeClass('iconpla-plus-circled').addClass('iconpla-minus-circled');
  $('.strings tr.file').show();
});
$('.open-missing').click(function() {
  $('.strings tr.string.missing td.toggler').removeClass('iconpla-plus-circled').addClass('iconpla-minus-circled');
  $('.strings tr.file.string-missing').show();
});
$('.close-all').click(function() {
  $('.strings tr.string td.toggler').removeClass('iconpla-minus-circled').addClass('iconpla-plus-circled');
  $('.strings tr.file').hide();
});

$('.tiptip').tipTip({
  delay: 0,
  fadeIn: 200,
  fadeOut: 200,
  defaultPosition: 'right'
});
{/literal}{/footer_script}

{html_style}
.strings tr td:nth-last-child(-n+{math equation="2+x" x=$PLA_LANG_FILES|@count}) {ldelim}
  text-align:center;
}
{/html_style}

<form class="properties">
<fieldset>
  <legend>{'Analysis results'|@translate}</legend>
  
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
    {foreach from=$PLA_LANG_FILES item=lang_file}
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
      <td>
        {$string|htmlspecialchars}
        {if isset($data.warnings)}<span class="iconpla-attention-circled tiptip" title="{'<br>'|@implode:$data.warnings}"></span>{/if}
      </td>
      {if $data.is_admin}<td class="text-admin">{'Admin'|@translate}</td>
      {else}<td class="text-common">{'Common'|@translate}</td>{/if}
    {foreach from=$PLA_LANG_FILES item=lang_file}
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
      {foreach from=$PLA_LANG_FILES item=lang_file}
        <td>{if $lang_file|in_array:$file_data.lang_files}<b>{'Yes'|@translate}</b>{else}{'No'|@translate}{/if}</td>
      {/foreach}
        <td></td>
        <td></td>
      </tr>
    {foreachelse}
      <tr class="file string-{$data.stat} useless">
        <td></td>
        <td><i>{'Unused'|@translate}</i></td>
        {'<td></td>'|str_repeat:(3+$PLA_LANG_FILES|@count)}
      </tr>
    {/foreach} {* <!-- end file --> *}
  {/foreach} {* <!-- end string --> *}
  </tbody>
  
  <tfoot>
    <tr>
      <th></th>
      <th>{'%d strings : %d missing and %d useless.'|@translate|sprintf:$PLA_COUNTS.total:$PLA_COUNTS.missing:$PLA_COUNTS.useless}</th>
      {'<th></th>'|str_repeat:(3+$PLA_LANG_FILES|@count)}
    </tr>
  </tfoot>
  </table>
</fieldset>
</form>