/*
�������ƣ�doMoveOption
�������ܣ����ض�option��Դselect�ƶ���Ŀ��select
���������src����Դselect
          dst��Ŀ��select
          index����Ҫ�ƶ���option��Դselect�е�λ��
�����������
*/
function doMoveOption(src, dst, index){
  var oOption = document.createElement("OPTION");
  oOption.text = src[index].text;
  oOption.value = src[index].value;
  dst.add(oOption);
  src.remove(index);
}

/*
�������ƣ�moveOption
�������ܣ���Դselect��ѡ�е�option�ƶ���Ŀ��select
���������src����Դselect
          dst��Ŀ��select
�����������
*/
function moveOption(src, dst){
  var oSrc = document.all(src);
  var oDst = document.all(dst);
  for(var i = oSrc.length - 1; i >= 0; i--)
    if(oSrc[i].selected)
      doMoveOption(oSrc, oDst, i);
}

/*
�������ƣ�formChkIds
�������ܣ���ѡ�е�option��id�����,�ָ����ַ���
���������oSelect��ѡ���select
���������ѡ�е���,�ָ���option value
*/
function formChkIds(oChk){
  var strReturn = "";
  var length = document.all(oChk).length;
  if(length > 1){
    for(var i = 0; i < length; i++)
      if(document.all(oChk)[i].checked)
        strReturn = strReturn + document.all(oChk)[i].value + ",";
  }
  else
    if(document.all(oChk).checked)
      strReturn = document.all(oChk).value;
  if(strReturn.substr(strReturn.length - 1, 1) == ",")
    strReturn = strReturn.substr(0, strReturn.length - 1);
  return strReturn;
}

/*
�������ƣ�formAllOptionIds
�������ܣ���ȫ��option��id�����,�ָ����ַ���
���������oSelect��ѡ���select
���������ȫ������,�ָ���option value
*/
function formAllOptionIds(oSelect){
  var strReturn = "";
  for(var i = 0; i < document.all(oSelect).length; i++)
    strReturn = strReturn + document.all(oSelect)[i].value + ",";
  if(strReturn.substr(strReturn.length - 1, 1) == ",")
    strReturn = strReturn.substr(0, strReturn.length - 1);
  return strReturn;
}

/*
�������ƣ�oCheckAll_onclick
�������ܣ�����ȫ��ѡ�С���ѡ��
���������oSelAll��ȫ��ѡ��ѡ�� oSel��ѡ���
�����������
*/
function oCheckAll_onclick(oSelAll, oSel){
  if(typeof(document.all(oSelAll)) != "object" || document.all(oSelAll) == null)
    return;
  if(typeof(document.all(oSel)) != "object" || document.all(oSel) == null)
    return;
  var length = document.all(oSel).length;
  var check = document.all(oSelAll).checked;
  if(length > 1)
    for(var i = 0; i < length; i++)
      document.all(oSel)[i].checked = check;
  else
    document.all(oSel).checked = check;
}

/*
�������ƣ�oCheck_onclick
�������ܣ�������ѡ���ѡ��ʱ��ȫ��ѡ�С���ѡ��
���������oSelAll��ȫ��ѡ��ѡ�� oSel��ѡ���
�����������
*/
function oCheck_onclick(oSelAll, oSel){
  if(typeof(document.all(oSelAll)) != "object" || document.all(oSelAll) == null)
    return;
  if(typeof(document.all(oSel)) != "object" || document.all(oSel) == null)
    return;
  var length = document.all(oSel).length;
  var check = true;
  if(length > 1){
    for(var i = 0; i < length; i++)
      if(!document.all(oSel)[i].checked){
        check = false;
        break;
      }
  }
  else
    check = document.all(oSel).checked;
  document.all(oSelAll).checked = check;
}

/*
�������ƣ�btnCheckAll_onclick
�������ܣ�����ȫ��ѡ�С���ť
���������oSel��ѡ���
�����������
*/
function btnCheckAll_onclick(oSel){
  if(typeof(document.all(oSel)) != "object" || document.all(oSel) == null)
    return;
  var length = document.all(oSel).length;
  if(length > 1)
    for(var i = 0; i < length; i++)
      document.all(oSel)[i].checked = true;
  else
    document.all(oSel).checked = true;
}
