// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function   locking(layerid)
{   
              $('ly').style.display = "block";   
			  $('ly').style.width=document.body.clientWidth;   
			  $('ly').style.height=document.body.clientHeight;   
			  $(layerid).style.display='block'; 
			  $(layerid).style.left = (parseInt(document.body.clientWidth)-parseInt($(layerid).style.width))/2 + "px";
			  new Effect.Highlight(layerid);
}   

function   Lock_CheckForm(layerid)
{   
			  $('ly').style.display='none';
			  $(layerid).style.display='none';
			  return   false;   
}   