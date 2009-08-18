function enablePngImages() {
  var version = parseFloat(navigator.appVersion.split("MSIE")[1]);
  if (version == 6.0 && (document.body.filters)) {
    var imgArr = document.getElementsByTagName("IMG");
    for(var i=0, j=imgArr.length; i<j; i++){
      if(imgArr[i].src.toLowerCase().lastIndexOf(".png") != -1){
        imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + imgArr[i].src + "', sizingMethod='scale')";
        imgArr[i].src = "/img/clear.gif";
      }
   }   
 
   imgArr = $(".folder_button");
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
    imgArr = $(".main_button");
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    
    imgArr = $(".login_button");
   for(var i=0, j=imgArr.length; i<j; i++){
        if(imgArr[i].currentStyle.backgroundImage.lastIndexOf(".png") != -1){
              var img = imgArr[i].currentStyle.backgroundImage.substring(5,imgArr[i].currentStyle.backgroundImage.length-2);
              imgArr[i].style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+img+"', sizingMethod='crop')";
              imgArr[i].style.backgroundImage = "url(/img/clear.gif)";
          }
    }
    

  }
}

window.onload = function() {
  enablePngImages();
}