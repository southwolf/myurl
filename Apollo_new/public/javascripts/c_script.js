<!-- 
//定义菜单显示的外观，可以从上面定义的2种格式中选择其一
var menuskin = "skin1"; 
//是否在浏览器窗口的状态行中显示菜单项目条对应的链接字符串
var display_url = 0; 

function showmenuie5() {
//获取当前鼠标右键按下后的位置，据此定义菜单显示的位置
var rightedge = document.body.clientWidth-event.clientX;
var bottomedge = document.body.clientHeight-event.clientY;

//如果从鼠标位置到窗口右边的空间小于菜单的宽度，就定位菜单的左坐标（Left）为当前鼠标位置向左一个菜单宽度
if (rightedge <ie5menu.offsetWidth)
ie5menu.style.left = document.body.scrollLeft + event.clientX - ie5menu.offsetWidth;
else
//否则，就定位菜单的左坐标为当前鼠标位置
ie5menu.style.left = document.body.scrollLeft + event.clientX;

//如果从鼠标位置到窗口下边的空间小于菜单的高度，就定位菜单的上坐标（Top）为当前鼠标位置向上一个菜单高度
if (bottomedge <ie5menu.offsetHeight)
ie5menu.style.top = document.body.scrollTop + event.clientY - ie5menu.offsetHeight;
else
//否则，就定位菜单的上坐标为当前鼠标位置
ie5menu.style.top = document.body.scrollTop + event.clientY;

//设置菜单可见
ie5menu.style.visibility = "visible";
return false;
}
function hidemenuie5() {
//隐藏菜单
//很简单，设置visibility为hidden就OK！
ie5menu.style.visibility = "hidden";
}

function highlightie5() {
//高亮度鼠标经过的菜单条项目

//如果鼠标经过的对象是menuitems，就重新设置背景色与前景色
//event.srcElement.className表示事件来自对象的名称，必须首先判断这个值，这很重要！
if (event.srcElement.className == "menuitems") {
event.srcElement.style.backgroundColor = "highlight";
event.srcElement.style.color = "white";

//将链接信息显示到状态行
//event.srcElement.url表示事件来自对象表示的链接URL
if (display_url)
window.status = event.srcElement.url;
   }
}

function lowlightie5() {
//恢复菜单条项目的正常显示

if (event.srcElement.className == "menuitems") {
event.srcElement.style.backgroundColor = "";
event.srcElement.style.color = "black";
window.status = "";
   }
}

//右键下拉菜单功能跳转
function jumptoie5() {
//转到新的链接位置
var seltext=window.document.selection.createRange().text
if (event.srcElement.className == "menuitems") {
//如果存在打开链接的目标窗口，就在那个窗口中打开链接
if (event.srcElement.getAttribute("target") != null)
window.open(event.srcElement.url, event.srcElement.getAttribute("target"));
else
//否则，在当前窗口打开链接
window.location = event.srcElement.url;
   }
}
//-->