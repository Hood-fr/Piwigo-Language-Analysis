{combine_css path=$PLA_PATH|cat:'template/style.css'}
{combine_css path=$PLA_PATH|cat:'template/fontello/css/fontello_pla.css'}

<div class="titrePage">
	<h2>
    Language Analysis
    {if isset($PLA_PLUGIN)}[{$PLA_PLUGIN.name}]{/if}
  </h2>
</div>

{include file=$PLA_ABS_PATH|cat:'template/'|cat:$PLA_STEP|cat:'.tpl'}

{if isset($U_BACK)}
<p style="text-align:left;margin-left:20px;"><a href="{$U_BACK}" class="buttonLike">{'Back'|translate}</a></p>
{/if}