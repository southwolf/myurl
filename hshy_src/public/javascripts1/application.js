
function enablePngImages() {
  var version = parseFloat(navigator.appVersion.split("MSIE")[1]);
  if (version == 6.0 && (document.body.filters)) {
    var imgArr = document.getElementsByTagName("IMG");
    for(var i=0, j=imgArr.length; i<j; i++){
      if(imgArr[i].src.toLowerCase().lastIndexOf(".png") != -1){
        imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + imgArr[i].src + "', sizingMethod='auto')";
        imgArr[i].src = "/img/clear.gif";
      }
   }   

   imgArr = $$(".Main_ToolBar_bg");
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
    imgArr = $$(".Main_ToolBar_bg_left") ;
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
    imgArr = $$(".Main_ToolBar_bg_right");
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
    imgArr = $$(".Main_ToolBar_textlabel_bg_left") ;
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
     imgArr = $$(".Main_ToolBar_textlabel_bg_right") ;
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
    imgArr = $$(".Button_left");
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='scale')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
    imgArr = $$(".Button_text");
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='scale')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
    imgArr = $$(".Button_right");
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='scale')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
  
//    
//   var  elements = $$(".Main_ToolBar_bg") ;
//   for(var i=0; i<elements.length;  i++){
//        elements[i].className = "Main_ToolBar_bg_ie6";
//    }


  }
}

window.onload = function() {
  enablePngImages();
}

//
//if (navigator.platform == "Win32" && navigator.appName == "Microsoft Internet Explorer" && window.attachEvent) {
//    window.attachEvent("onload", enableAlphaImages);
//}
//
//function enableAlphaImages(){
//   var imgArr = document.getElementsByTagName("IMG");
//   var version = parseFloat(navigator.appVersion.split("MSIE")[1]);
//   if (version == 6.0 && (document.body.filters)) {
//        for (var i=0; i<document.all.length; i++){
//            var obj = document.all[i];
//            var bg = obj.currentStyle.backgroundImage;
//            var img = document.images[i];
//            if (bg && bg.match(/\.png/i) != null) {
//                var img = bg.substring(5,bg.length-2);
//                var offset = obj.style["background-position"];
//                obj.style.filter =
//                    "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
//                obj.style.backgroundImage = "url('/img/clear.gif')";//Ìæ»»Í¸Ã÷PNGµÄÍ¼Æ¬
//                obj.style["background-position"] = offset; // reapply
//            } else if (img && img.src.match(/\.png$/i) != null) {
//                var src = img.src;
//                img.style.width = img.width + "px";
//                img.style.height = img.height + "px";
//                img.style.filter =
//                    "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+src+"', sizingMethod='crop')"
//                img.src = "/img/clear.gif";//Ìæ»»Í¸Ã÷PNGµÄÍ¼Æ¬
//            }
//        }
//    }
//}