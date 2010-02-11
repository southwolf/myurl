/*
	�������ƣ�trim
	��������: ȥ���ַ���ͷ����β���Ŀո�
	����������ַ�������
	����������������Ӵ�
*/
function trim(str){
	return str.replace(/(^\s*)|(\s*$)/g, "");
}

function isChn(d) {
 actlen=d.length;
 for(i=0;i<d.length;i++)
 if (d.substr(i,1)>"~")
    actlen+=1;
 if( actlen>d.length )
   return true;
 return false;
}

//��֤������ַ����Ƿ�Ϊ��
function isNull(inputStr)
{
    if (inputStr == null || inputStr == "")
    {
        return true;
    }
    return false;
}

/*  �������ܣ��жϴ�������Ƿ�Ϊyyyy-mm-dd��
			  yyyy/mm/dd��ʽ����ȷ����
			  2001/01/2��2001-3-04Ҳ������ĸ�ʽ
			  ����ǣ��򷵻�һ����Ӧ�����ڶ���
			  ������򷵻�false
*/
function isDate(strDate){
	var regYear = /\d{4}[-/]/g;	//year pattern
	var regMonth;
	var regDay =  /\d{1,2}/g;;
	var chrSeperator;
	var arr,str;
	if ((arr = regYear.exec(strDate)) == null)
		return false;
	var intYearlen = arr.lastIndex - arr.index - 1;
	if (arr.index != 0 || (intYearlen != 4 && intYearlen != 2))
		return false;
	str = arr[0];
	chrSeperator = str.charAt(str.length - 1);  // get the seperator ('-' or '/')
	intYear = parseInt(str.substr(0, str.length - 1));	// get the year
	if (intYear < 1900 || intYear > 2099)  //Error Year
		return false;

	strDate = strDate.substr(arr.lastIndex);
	if (chrSeperator == "-")
		regMonth = /\d{1,2}[-]/g;
	else
		regMonth = /\d{1,2}[/]/g;
	if ((arr = regMonth.exec(strDate)) == null)
		return false;
	if (arr.index != 0)
		return false;
	str = arr[0];
	if (str.charAt(0) == '0') {
		intMonth = parseInt(str.substr(1, str.length - 2)); // get the month
	} else {
		intMonth = parseInt(str.substr(0, str.length - 1)); // get the month
	}
	if (intMonth < 1 || intMonth > 12) //Error Month
		return false;

	strDate = strDate.substr(arr.lastIndex);

	if ((arr = regDay.exec(strDate)) == null)
		return false;
	if (arr.index != 0 || arr.lastIndex != strDate.length)
		return false;
	str = arr[0];
	if (str.charAt(0) == '0') {
		intDay = parseInt(str.substr(1, str.length - 1)); // get the day
	} else {
		intDay = parseInt(str); // get the day
	}
	if (intDay < 1 || intDay > 31)  //Error Day
		return false;

	datDate = new Date(intYear, intMonth - 1, intDay); //Test the Date
	if (isNaN(datDate))  //Error Date Format
		return false;
	if (datDate.getMonth() != intMonth - 1 || datDate.getDate() != intDay)  //invalid date such as '1999/02/29' and '1999/04/31'
		return false;
	return datDate;  //Return the Date in parsed format
}

function isBirthDate(d) {
	var first,second,yy,mm,dd;
	var today = new Date();
	if(d.indexOf("/")!=-1)
	{
		first=d.indexOf("/");
		second=d.lastIndexOf("/");
		if(second==first) return false;
		yy=parseInt(d.substring(0,first));
		if ( d.substr(first + 1, 1) == '0' )
			mm=parseInt(d.substring(first+2,second));
		else
			mm=parseInt(d.substring(first+1,second));
		if ( d.substr(second + 1, 1) == '0' )
			dd=parseInt(d.substring(second+2,d.length));
		else
			dd=parseInt(d.substring(second+1,d.length));
		if (isNaN(yy)) { //Error Year Format
			return false;
		}
		if (yy<30)
			yy += 2000;
		else if (yy <100 && yy >= 30)
			yy += 1900;
		if( yy < 1900 || yy>2069) return false;
		if (isNaN(mm) || mm < 1 || mm > 12) { //Error Month Format
			return false;
		}
		if (isNaN(dd) || dd < 1 || dd > 31) { //Error Month Format
			return false;
		}
		d = new Date(yy, mm - 1, dd); //Test the Date
		if (isNaN(d)) { //Error Date Format
			return false;
		}
		if (d.getMonth() != mm - 1 || d.getDate() != dd) { //invalid date such as '1999/02/29' and '1999/04/31'
			return false;
		}
		if ( yy + 16 > today.getFullYear() ) return false;
		return d.toLocaleString();  //Return the Date in parsed format
	}
	else if(d.indexOf("-")!=-1)
	{
		first=d.indexOf("-");
		second=d.lastIndexOf("-");
		if(second==first) return false;
		yy=parseInt(d.substring(0,first));
		if ( d.substr(first + 1, 1) == '0' )
			mm=parseInt(d.substring(first+2,second));
		else
			mm=parseInt(d.substring(first+1,second));
		if ( d.substr(second + 1, 1) == '0' )
			dd=parseInt(d.substring(second+2,d.length));
		else
			dd=parseInt(d.substring(second+1,d.length));
		if (isNaN(yy)) { //Error Year Format
			return false;
		}
		if (yy<30)
			yy += 2000;
		else if (yy <100 && yy >= 30)
			yy += 1900;
		if( yy < 1950 || yy>2069) return false;
		if (isNaN(mm) || mm < 1 || mm > 12) { //Error Month Format
			return false;
		}
		if (isNaN(dd) || dd < 1 || dd > 31) { //Error Month Format
			return false;
		}
		d = new Date(yy, mm - 1, dd); //Test the Date
		if (isNaN(d)) { //Error Date Format
			return false;
		}
		if (d.getMonth() != mm - 1 || d.getDate() != dd) { //invalid date such as '1999/02/29' and '1999/04/31'
			return false;
		}
		if ( yy + 16 > today.getFullYear() ) return false;
		return d.toLocaleString();  //Return the Date in parsed format
	}
	else
		return false;
}

function isInt(n) {
	var i = parseInt(n*1);
	if (i == NaN) {
		return false;
	}
	if (i != n){
		return false;
	}
	return true;
}

function isDecimal(str,f,n) {
    var p=str.indexOf(".");
    var int,flt;

    if(str=="") return true;
    if (p<0) { p=str.length ;}
    int=str.substr(0,p);
    flt=str.substr(p+1);
    if (isInt(int)==false) {
       return false;
    }
    if (flt!='') {
       if (isInt(flt)==false) {
          return false;
       }
    }
    if ((int.length > f-n) || (flt.length > n)) {
       return false;
    }
    return true;
}

function isMail(str) {
	if (trim(str) == ""){
		return true;
	}
    var a=str.indexOf("@")+1;
    var p=str.indexOf(".")+1;
    if(str.indexOf("'") > 0)
		return false;
	if(str.indexOf('"') > 0)
		return false;
    if (a<2)
       return false;
    if (p<1)
       return false;
    if (p<a+2)
       return false;
    if (str.length==p)
       return false;
    return true;
}

function isFloat(str) {
	var ch=str.charAt(0);
	if( ch == "." ) return false;
    for (var i=0; i < str.length; i++)
	{	ch=str.charAt(i);
		if ((ch != ".") && (ch != "0") && (ch != "1") && (ch != "2") && (ch != "3") && (ch != "4") && (ch != "5") && (ch != "6") && (ch != "7") && (ch != "8") && (ch != "9"))
			return false;
	}
    return true;
}

function isNumber(str) {
    for (var i=0; i < str.length; i++)
	{	var ch=str.charAt(i);
		if ((ch != "0") && (ch != "1") && (ch != "2") && (ch != "3") && (ch != "4") && (ch != "5") && (ch != "6") && (ch != "7") && (ch != "8") && (ch != "9"))
			return false;
	}
    return true;
}

function CheckUserInput(vstrInput) {
	var intIndex;
	var intCharCount;
	for(intIndex = 0; intIndex < vstrInput.length; intIndex++){
		if (vstrInput.charCodeAt(intIndex) < 48)
			return false;
		if ((vstrInput.charCodeAt(intIndex) > 57) && (vstrInput.charCodeAt(intIndex) < 64))
			return false;
		if ((vstrInput.charCodeAt(intIndex) > 90) && (vstrInput.charCodeAt(intIndex) < 97))
			return false;
		if (vstrInput.charCodeAt(intIndex) > 122)
			return false;
	}
	return true;
}
function isPhone(str){
	var intIndex;
	var intCharCount;
	for(intIndex = 0; intIndex < str.length; intIndex++){
		if(str.charCodeAt(intIndex) < 32)
			return false;
		if(str.charCodeAt(intIndex) == 34)
			return false;
		if(str.charCodeAt(intIndex) == 39)
			return false;
		if(str.charCodeAt(intIndex) > 126)
			return false;
	}
	return true;
}

/*
	�������ƣ�checkString()
	��������: ���ܰ���&����������<��>��:��;�������ַ�;
		�Ϸ��ַ���32���ո񣩡�48~57�����֣���65~90����д�ַ�����95���»��ߣ���97~122��Сд�ַ�����>127�����֣���
	����������ַ�������
	����������������Ӵ�
*/
function checkString(str){
	var strChar = str;
	var isValid = true;
	for (var i = 0; i < str.length; i++){
		if ( (str.charCodeAt(i) == 32) || ((str.charCodeAt(i) >= 48) && (str.charCodeAt(i) <= 57)) || ((str.charCodeAt(i) >= 65) && (str.charCodeAt(i) <= 90)) || (str.charCodeAt(i) == 95) || ((str.charCodeAt(i) >= 97) && (str.charCodeAt(i) <= 122)) || (str.charCodeAt(i) > 127) ) {
			// do nothing
		} else {
			isValid = false;
			break;
		}
	}
	return isValid;
}
/*
	�������ƣ�selectToString(selectObject)
	��������: ��select�е�������ַ������Զ��ŷָ�
	���������select����
	����������ַ���
*/
function selectToString(selectObject){
	var str = "";
	for(var i = 0; i < selectObject.length; i++){
		str = str + selectObject(i).value + ",";
	}
	if(str.substr(str.length - 1, 1) == ",")
		str = str.substr(0, str.length - 1);
	return str;
}
/*
	�������ƣ�CheckPostCode(str)
	��������: ����ʱ�ĺϷ���
	���������str���������ַ�
	���������true or false
*/
function CheckPostCode(str){
	if (trim(str) == ""){
		return true;
	}
	for (var i=0; i < str.length; i++){
		var ch=str.charAt(i);
		if ((ch != "0") && (ch != "1") && (ch != "2") && (ch != "3") && (ch != "4") && (ch != "5") && (ch != "6") && (ch != "7") && (ch != "8") && (ch != "9"))
			return false;
		else
			return true;
	}
}

/*
�������ܣ���������ҳ����Զ��Ļ�����
by:������
������
alterKeyCode:�����ӵļ�ֵ������ǻس�������Ϊ13
alterInGroup:ת�����ڷ�Χ��IDֵ��ת�����ڷ�Χ�����Ǿ�����ͬIDֵ��һ���ؼ�����
��ע��
Ҫʹ�ñ�����������tabIndex����������������
��������ӵļ�ֵΪ13���򱾺�������textarea��ͣ��������Ϊ�ڲ�����
*/
function alterElement(alterKeyCode,alterInGroup){
	var basicIndex = document.all(alterInGroup)[0].tabIndex;
	if(event.keyCode==alterKeyCode){
		switch(event.srcElement.id){
			case alterInGroup:
				var iIndex = event.srcElement.tabIndex;
				if(event.srcElement.type != "textarea")
					event.keyCode = null;

				iIndex ++;
				iIndex -= basicIndex;

				if(iIndex==document.all(alterInGroup).length-1){
					if(!document.all(alterInGroup)[iIndex].disabled)
						document.all(alterInGroup)[iIndex].select();
					else{
						for(var i=iIndex+1;i<document.all(alterInGroup).length;i++){
							if(!document.all(alterInGroup)[i].disabled){
								event.keyCode = null;
								document.all(alterInGroup)[i].focus();
							}
						}
					}
					return true;
				}

				if(iIndex>=document.all(alterInGroup).length)
					return true;
				if(!document.all(alterInGroup)[iIndex].disabled){
					document.all(alterInGroup)[iIndex].focus();
				}
				else{
					for(var i=iIndex+1;i<document.all(alterInGroup).length;i++){
						if(!document.all(alterInGroup)[i].disabled){
							event.keyCode = null;
							document.all(alterInGroup)[i].focus();
						}
					}
				}

				return true;
				break;
			default:
				if(!document.all(alterInGroup)[0].disabled)
					document.all(alterInGroup)[0].focus();
				else{
					for(var i=1;i<document.all(alterInGroup).length;i++){
						if(!document.all(alterInGroup)[i].disabled){
							event.keyCode = null;
							document.all(alterInGroup)[i].focus();
						}
					}
				}
				return true;
		}
	}
	return true;
}

/**
 *�������ƣ�selectByValue
 *���������srcName--Select�ؼ�������
 *          value----Ҫѡ���ֵ
 *����ֵ  ����
 *����    ��selectByValue("s", "2")
 */
function selectByValue(srcName, value) {
        var o = document.all(srcName);
        if( o==null || o.tagName!="SELECT" ) return;
        var length = o.options.length;
        for( var i=0; i<length; i++ ) {
                var oOption = o.options[i];
                if( value==oOption.value) {
                        o.selectedIndex = i;
                        return;
                }
        }
}

function selectByText(srcName, text) {
        var o = document.all(srcName);
        if( o==null || o.tagName!="SELECT" ) return;
        var length = o.options.length;
        for( var i=0; i<length; i++ ) {
                var oOption = o.options[i];
                if( text==oOption.text) {
                        o.selectedIndex = i;
                        return;
                }
        }
}
/**
 * ���������б��ѡ��
 * @return
 */
function move(listnamefrom,listnameto){
 	for(var i=eval(listnamefrom).length-1;i>=0;i--){
		if(eval(listnamefrom).item(i).selected){
			var selValue=eval(listnamefrom).item(i).value;
			var selText=eval(listnamefrom).item(i).text;
			var listitem=window.Option.create(selText,selValue);
			eval(listnameto).add(listitem);
			eval(listnamefrom).remove(i);
		}
	}
}