{footer_script}
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

$('.switch-button.ignore span').click(function() {
  if ($(this).hasClass('active')) {
    $(this).removeClass('active');
    $(this).next('input').val('false');
  }
  else {
    $(this).addClass('active');
    $(this).next('input').val('true');
  }
});

$('.folder > td > .switch-button span').click(function() {
  $(this).removeClass('active')
    .closest('.folder').next('.nested')
    .find('tr:not(.folder) > td > .switch-button span[data-val="'+ $(this).data('val') +'"]')
    .trigger('click');
});
{/footer_script}

<form method="POST" action="{$F_ACTION}" class="properties">
<fieldset>
  <legend>{'Select dependencies'|translate}</legend>
  
  {include file=$PLA_ABS_PATH|cat:'template/config_list.inc.tpl' files=$PLA_FILES level=0 path=""}
  
  <p class="formButtons"><input type="submit" value="{'Continue'|translate}"></p>
</fieldset>
</form>