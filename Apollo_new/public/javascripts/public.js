/**
 * 除去字符串两边的空格
 */
String.prototype.trim = function()
{
    return this.replace(/(^\s*)|(\s*$)/g, "");
}

//Name: isNull（输入的字符串是否为空）
function isNull(inputStr) {
if (inputStr == null || inputStr == "") {
  return true;
}
return false;
}


/**判断字符串str中是否含有系统保留（如",(,),[,],',<,>）的字符。
 * 如果含有非法字符则返回true，否则返回false.
 */
function hasIllegalChar(str){
    regexp = /^.*['"<>\[\]()].*$/;
    return regexp.test( str );
}

/**
* 判断items中是否有选中的条目
* @items 条目对象
* @return 有选中的条目，返回true；否则返回false
*/
function hasSelectedItem(items)
{
    //条目不存在
    if(items == null ){
      return false;
    }
    selected = false;
    if(items.length == null)
    {
        //只有一个选项
        if(items.checked)
            selected = true;
    }
    else
    {
        //存在多个个选项
        for(i = 0;i < items.length;i++)
        {
            if(items[i].checked)
                selected = true;
        }
    }
    return selected;
}

/**
* 选中或不选中所有条目
* @items 条目对象
* @checked 指定是否选中，true或者false
*/
function CheckAll(items, checked)  {
    //条目不存在
    if(items == null )
        return false;

    if(items.length == null)
    {
        //只有一个选项
        items.checked = checked;
    }
    else
    {
        //存在多个个选项
        for(i = 0;i < items.length;i++)
            items[i].checked = checked;
    }
}




/**
* 判断字符串的长度
*/
function getLength(str)
{
    var len = 0;
    if(str != null)
    {
    	for(i=0; i< str.length; i++)
    	{
            //区分双字节字符和单字节字符
            if(str.charCodeAt(i) > 127)
            	len += 2;
            else
            	len +=1;
    	}
    }
    return len;
}


/**
 * 清除维度下拉列表框内容
 * @oSelect 列表对象
 */
function clearSelect(oSelect){
	var oOptions = oSelect.options;
        var longths = oOptions.length;
	for(i=0;i<=longths;i++){
		oOptions.remove(0);
	}
}

/**
 * 比较两个日期Date类型的对象大小
 * @param date1 日期1
 * @param date2 日期2
 * @return date1 > date2，返回值>0；date1 = date2，返回0；date1 < date2，返回值<0；
 */
function compareDate(date1, date2)
{
    var result = 0;

    //比较年
    result = date1.getYear() - date2.getYear();

    if(result != 0)
    {
        return result;
    }

    //比较月
    result = date1.getMonth() - date2.getMonth();

    if(result != 0)
    {
        return result;
    }

    //比较天
    result = date1.getDate() - date2.getDate();

    if(result != 0)
    {
        return result;
    }

    //比较时间
    result = date1.getTime() - date2.getTime();

    if(result != 0)
    {
        return result;
    }

    return result;
}

/**去除父帧。解决在有帧（frame或者iframe）的情况下，需要返回主页或者重新登录会出现在某个帧而不是整个窗口的问题。*/
function getRidOfParentFrame(){
  if(window.top.location != window.location)
    window.top.location = window.location;
}
//ie版本判断,其他浏览器没有判断版本
function judgeVersionOfBrowser(){
   var IS = new Object();
   IS.apv = navigator.appVersion.toLowerCase();
   IS.major = parseInt(IS.apv);
  IS.ie = ((IS.apv.indexOf("msie") != -1) && (IS.apv.indexOf('opera')==-1) && (IS.apv.indexOf('msn')==-1)) ;
  IS.notIE = (IS.apv.indexOf("msie") == -1);
  //ie版本5.0以上
  IS.ieOfThisSystem = (IS.ie && (IS.apv.indexOf("msie 4.")==-1) && (IS.major >= 4) && (IS.apv.indexOf("msie 5.0")==-1));
  if(IS.ieOfThisSystem || IS.notIE){
    return true;
  }else{
    return false;
  }
}
//验证email的合法性
function ismail(mail)
{
  return(new RegExp(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/).test(mail));
}

function toggle( id, showName, hideName ) 
{
    if( showName == null 
    	|| showName.length == 0 )
    	showName = "显示";
    
    if( hideName == null 
    	|| hideName.length == 0 )
    	hideName = "隐藏";
    	
    var element = document.getElementById(id);
    with (element.style) {
        if ( display == "none" ){
            display = ""
        } else{
            display = "none"
        }
    }
    var text = document.getElementById(id + "-switch").firstChild;
    if (text.nodeValue == showName) {
        text.nodeValue = hideName;
    } else {
        text.nodeValue = showName;
    }
}

function removeHiddenField( oForm, oFieldName ) {
	var cols = new Array();
	var count = 0;
	
	var oChildren = oForm.getElementsByTagName( "input" );
	
	// 查找隐藏域
	for(var i = 0; i < oChildren.length; i++)
	{
	        if( oChildren[i].name == oFieldName )
	        {
			cols[count] = oChildren.item(i);
			count++;
		}
	}
		
	for(var i = 0; i < cols.length; i++)
	{
		oForm.removeChild( cols[i] );
	}
}