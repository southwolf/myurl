/**
 * ��ȥ�ַ������ߵĿո�
 */
String.prototype.trim = function()
{
    return this.replace(/(^\s*)|(\s*$)/g, "");
}

//Name: isNull��������ַ����Ƿ�Ϊ�գ�
function isNull(inputStr) {
if (inputStr == null || inputStr == "") {
  return true;
}
return false;
}


/**�ж��ַ���str���Ƿ���ϵͳ��������",(,),[,],',<,>�����ַ���
 * ������зǷ��ַ��򷵻�true�����򷵻�false.
 */
function hasIllegalChar(str){
    regexp = /^.*['"<>\[\]()].*$/;
    return regexp.test( str );
}

/**
* �ж�items���Ƿ���ѡ�е���Ŀ
* @items ��Ŀ����
* @return ��ѡ�е���Ŀ������true�����򷵻�false
*/
function hasSelectedItem(items)
{
    //��Ŀ������
    if(items == null ){
      return false;
    }
    selected = false;
    if(items.length == null)
    {
        //ֻ��һ��ѡ��
        if(items.checked)
            selected = true;
    }
    else
    {
        //���ڶ����ѡ��
        for(i = 0;i < items.length;i++)
        {
            if(items[i].checked)
                selected = true;
        }
    }
    return selected;
}

/**
* ѡ�л�ѡ��������Ŀ
* @items ��Ŀ����
* @checked ָ���Ƿ�ѡ�У�true����false
*/
function CheckAll(items, checked)  {
    //��Ŀ������
    if(items == null )
        return false;

    if(items.length == null)
    {
        //ֻ��һ��ѡ��
        items.checked = checked;
    }
    else
    {
        //���ڶ����ѡ��
        for(i = 0;i < items.length;i++)
            items[i].checked = checked;
    }
}




/**
* �ж��ַ����ĳ���
*/
function getLength(str)
{
    var len = 0;
    if(str != null)
    {
    	for(i=0; i< str.length; i++)
    	{
            //����˫�ֽ��ַ��͵��ֽ��ַ�
            if(str.charCodeAt(i) > 127)
            	len += 2;
            else
            	len +=1;
    	}
    }
    return len;
}


/**
 * ���ά�������б������
 * @oSelect �б����
 */
function clearSelect(oSelect){
	var oOptions = oSelect.options;
        var longths = oOptions.length;
	for(i=0;i<=longths;i++){
		oOptions.remove(0);
	}
}

/**
 * �Ƚ���������Date���͵Ķ����С
 * @param date1 ����1
 * @param date2 ����2
 * @return date1 > date2������ֵ>0��date1 = date2������0��date1 < date2������ֵ<0��
 */
function compareDate(date1, date2)
{
    var result = 0;

    //�Ƚ���
    result = date1.getYear() - date2.getYear();

    if(result != 0)
    {
        return result;
    }

    //�Ƚ���
    result = date1.getMonth() - date2.getMonth();

    if(result != 0)
    {
        return result;
    }

    //�Ƚ���
    result = date1.getDate() - date2.getDate();

    if(result != 0)
    {
        return result;
    }

    //�Ƚ�ʱ��
    result = date1.getTime() - date2.getTime();

    if(result != 0)
    {
        return result;
    }

    return result;
}

/**ȥ����֡���������֡��frame����iframe��������£���Ҫ������ҳ�������µ�¼�������ĳ��֡�������������ڵ����⡣*/
function getRidOfParentFrame(){
  if(window.top.location != window.location)
    window.top.location = window.location;
}
//ie�汾�ж�,���������û���жϰ汾
function judgeVersionOfBrowser(){
   var IS = new Object();
   IS.apv = navigator.appVersion.toLowerCase();
   IS.major = parseInt(IS.apv);
  IS.ie = ((IS.apv.indexOf("msie") != -1) && (IS.apv.indexOf('opera')==-1) && (IS.apv.indexOf('msn')==-1)) ;
  IS.notIE = (IS.apv.indexOf("msie") == -1);
  //ie�汾5.0����
  IS.ieOfThisSystem = (IS.ie && (IS.apv.indexOf("msie 4.")==-1) && (IS.major >= 4) && (IS.apv.indexOf("msie 5.0")==-1));
  if(IS.ieOfThisSystem || IS.notIE){
    return true;
  }else{
    return false;
  }
}
//��֤email�ĺϷ���
function ismail(mail)
{
  return(new RegExp(/^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/).test(mail));
}

function toggle( id, showName, hideName ) 
{
    if( showName == null 
    	|| showName.length == 0 )
    	showName = "��ʾ";
    
    if( hideName == null 
    	|| hideName.length == 0 )
    	hideName = "����";
    	
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
	
	// ����������
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