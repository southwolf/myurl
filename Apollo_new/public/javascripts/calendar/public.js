/**��ձ���������
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
 *���URL�е��ύ�����������ź���Ĳ�����
  *������urlһ��Ϊwindow.location��param��Ҫȡ�Ĳ�����
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
/**���´��ڡ����ش򿪵Ĵ��ڡ�
*������window.openһ�� 
url:��ַ��	name���������ơ�	params����������
*/
function showMyDialog(url,name,params){
	//Ĭ��ֵ
	if(params==null) params="height=490,width=490,toolbar=no,menubar=no,scrollbars=yes,resizable=yes,left=130,top=40";
	var result=window.open(url,name,params);
	result.focus();
	return result;
}

/**ɾ�����ݡ�
data�����ݵ����ơ��磺��λ����
*/
function deleteData(data){
	var result=confirm("��ȷ��Ҫɾ��ѡ�еļ�¼ô��");
	if(result)
		showInfo("ɾ��"+data+"�ɹ���");
	else{
		showInfo("����ȡ����");
	}
}
/**�������ݡ�
data�����ݵ����ơ��磺��λ����
*/
function saveData(data){
	showInfo("����"+data+"�ɹ���");
}
/**
��ϵͳ��Ϣ��ʾ���ͻ���
str����Ϣ
*/
function showInfo(str){
	var now=new Date();
	window.parent.status=str
	+"  ����ʱ�䣺"+now.getHours()+":"+now.getMinutes()+":"+now.getSeconds();
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
    len = 0;
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
/**ȥ����֡���������֡��frame����iframe��������£���Ҫ������ҳ�������µ�¼�������ĳ��֡�������������ڵ����⡣*/
function getRidOfParentFrame(){
  if(window.parent.location != window.location)
    window.parent.location = window.location;
}


