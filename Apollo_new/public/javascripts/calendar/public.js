/**清空表单中所有域。
*/
function clearAll(){
	var temp;
	temp=document.all.tags("INPUT")
	for(i=0;i<temp.length;i++){
		if(temp[i].type=='text') temp[i].value='';
		if(temp[i].type=='checkbox' || temp[i].type=='radio') temp[i].checked=false;	
	}
	temp=document.all.tags("TEXTAREA")
	for(i=0;i<temp.length;i++){
		temp[i].value='';	
	}
	temp=document.all.tags("SELECT")
	for(i=0;i<temp.length;i++){
		temp[i].value='';	
	}
}
/**
 *获得URL中的提交参数，即？号后面的参数。
  *参数：url一般为window.location；param，要取的参数名
  */
function getURLParam(url,param){
	if (url == null) {alert('url cannot be null.');return '';}
	var searchStr=param+'=';
	var begin=url.indexOf(searchStr,url.lastIndexOf('?'));
	if(begin<0) return '';
	begin+=searchStr.length;	
	var end=url.indexOf('&',begin);
	if (end<0){
		end=url.length;
	}
	return url.substring(begin,end);
}
/**打开新窗口。返回打开的窗口。
*参数跟window.open一样 
url:网址。	name：窗口名称。	params：窗口属性
*/
function showMyDialog(url,name,params){
	//默认值
	if(params==null) params="height=490,width=490,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,left=130,top=40";
	var result=window.open(url,name,params);
	result.focus();
	return result;
}

/**删除数据。
data：数据的名称。如：单位性质
*/
function deleteData(data){
	var result=confirm("您确认要删除选中的记录么？");
	if(result)
		showInfo("删除"+data+"成功。");
	else{
		showInfo("操作取消。");
	}
}
/**保存数据。
data：数据的名称。如：单位性质
*/
function saveData(data){
	showInfo("保存"+data+"成功。");
}
/**
将系统消息显示给客户。
str：消息
*/
function showInfo(str){
	var now=new Date();
	window.parent.status=str
	+"  操作时间："+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
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
    len = 0;
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
/**去除父帧。解决在有帧（frame或者iframe）的情况下，需要返回主页或者重新登录会出现在某个帧而不是整个窗口的问题。*/
function getRidOfParentFrame(){
  if(window.parent.location != window.location)
    window.parent.location = window.location;
}


