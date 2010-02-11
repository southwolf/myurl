/*
函数名称：doMoveOption
函数功能：将特定option从源select移动到目的select
传入参数：src：来源select
          dst：目的select
          index：需要移动的option在源select中的位置
传出结果：无
*/
function doMoveOption(src, dst, index){
  var oOption = document.createElement("OPTION");
  oOption.text = src[index].text;
  oOption.value = src[index].value;
  dst.add(oOption);
  src.remove(index);
}

/*
函数名称：moveOption
函数功能：将源select中选中的option移动到目的select
传入参数：src：来源select
          dst：目的select
传出结果：无
*/
function moveOption(src, dst){
  var oSrc = document.all(src);
  var oDst = document.all(dst);
  for(var i = oSrc.length - 1; i >= 0; i--)
    if(oSrc[i].selected)
      doMoveOption(oSrc, oDst, i);
}

/*
函数名称：formChkIds
函数功能：将选中的option的id组成以,分隔的字符串
传入参数：oSelect：选择的select
传出结果：选中的以,分隔的option value
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
函数名称：formAllOptionIds
函数功能：将全部option的id组成以,分隔的字符串
传入参数：oSelect：选择的select
传出结果：全部的以,分隔的option value
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
函数名称：oCheckAll_onclick
函数功能：处理“全部选中”复选框
传入参数：oSelAll：全部选择复选框 oSel：选择框
传出结果：无
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
函数名称：oCheck_onclick
函数功能：处理单个选择框被选上时“全部选中”复选框
传入参数：oSelAll：全部选择复选框 oSel：选择框
传出结果：无
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
函数名称：btnCheckAll_onclick
函数功能：处理“全部选中”按钮
传入参数：oSel：选择框
传出结果：无
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
