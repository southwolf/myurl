/*----------------------------------------------------------------------------\
|                               XLoadTree 1.11                                |
|-----------------------------------------------------------------------------|
|                         Created by Erik Arvidsson                           |
|                  (http://webfx.eae.net/contact.html#erik)                   |
|                      For WebFX (http://webfx.eae.net/)                      |
|-----------------------------------------------------------------------------|
| An extension to xTree that allows sub trees to be loaded at runtime by      |
| reading XML files from the server. Works with IE5+ and Mozilla 1.0+         |
|-----------------------------------------------------------------------------|
|                   Copyright (c) 1999 - 2002 Erik Arvidsson                  |
|-----------------------------------------------------------------------------|
| This software is provided "as is", without warranty of any kind, express or |
| implied, including  but not limited  to the warranties of  merchantability, |
| fitness for a particular purpose and noninfringement. In no event shall the |
| authors or  copyright  holders be  liable for any claim,  damages or  other |
| liability, whether  in an  action of  contract, tort  or otherwise, arising |
| from,  out of  or in  connection with  the software or  the  use  or  other |
| dealings in the software.                                                   |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| This  software is  available under the  three different licenses  mentioned |
| below.  To use this software you must chose, and qualify, for one of those. |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| The WebFX Non-Commercial License          http://webfx.eae.net/license.html |
| Permits  anyone the right to use the  software in a  non-commercial context |
| free of charge.                                                             |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| The WebFX Commercial license           http://webfx.eae.net/commercial.html |
| Permits the  license holder the right to use  the software in a  commercial |
| context. Such license must be specifically obtained, however it's valid for |
| any number of  implementations of the licensed software.                    |
| - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
| GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt |
| Permits anyone the right to use and modify the software without limitations |
| as long as proper  credits are given  and the original  and modified source |
| code are included. Requires  that the final product, software derivate from |
| the original  source or any  software  utilizing a GPL  component, such  as |
| this, is also licensed under the GPL license.                               |
|-----------------------------------------------------------------------------|
| 2001-09-27 | Original Version Posted.                                       |
| 2002-01-19 | Added some simple error handling and string templates for      |
|            | reporting the errors.                                          |
| 2002-01-28 | Fixed loading issues in IE50 and IE55 that made the tree load  |
|            | twice.                                                         |
| 2002-10-10 | (1.1) Added reload method that reloads the XML file from the   |
|            | server.                                                        |
/ 2003-05-06 | Added support for target attribute                             |
|-----------------------------------------------------------------------------|
| Dependencies: xtree.js - original xtree library                             |
|               xtree.css - simple css styling of xtree                       |
|               xmlextras.js - provides xml http objects and xml document     |
|                              objects                                        |
|-----------------------------------------------------------------------------|
| Created 2001-09-27 | All changes are in the log above. | Updated 2003-05-06 |
\----------------------------------------------------------------------------*/


webFXTreeConfig.loadingText = "Waiting...";
webFXTreeConfig.loadErrorTextTemplate = "装入错误 \"%1%\"";
webFXTreeConfig.emptyErrorTextTemplate = "错误 \"%1%\" 不包含下级单位";

/*
 * WebFXCheckBoxLoadTree class
 */

function WebFXCheckBoxLoadTree(sText, bChecked, checkValue, sXmlSrc, sAction, sBehavior, sIcon, sOpenIcon) {
	// call super
	this.WebFXCheckBoxTree = WebFXCheckBoxTree;
	this.WebFXCheckBoxTree(sText, bChecked, checkValue, sAction, sBehavior, sIcon, sOpenIcon);

	// setup default property values
	this.src = sXmlSrc;
	this.loading = false;
	this.loaded = false;
	this.errorText = "";

	// if no src, do nothing
	if(this.src == null || this.src == "")
		return;

	// check start state and load if open
	if (this.open)
		_startLoadXmlTree_Checkbox(this.src, this);
	else {
		// and create loading item if not
		this._loadingItem = new WebFXCheckBoxTreeItem(webFXTreeConfig.loadingText);
		this.add(this._loadingItem);
	}
}

WebFXCheckBoxLoadTree.prototype = new WebFXCheckBoxTree;

// override the expand method to load the xml file
WebFXCheckBoxLoadTree.prototype._webfxtree_expand = WebFXCheckBoxTree.prototype.expand;
WebFXCheckBoxLoadTree.prototype.expand = function() {
	if (!this.loaded && !this.loading) {
		// load
		_startLoadXmlTree_Checkbox(this.src, this);
	}
	this._webfxtree_expand();
};

/*
 * WebFXCheckBoxLoadTreeItem class
 */

function WebFXCheckBoxLoadTreeItem(sText, bChecked, checkValue, sXmlSrc, sAction, eParent, sIcon, sOpenIcon) {
	// call super
	this.WebFXCheckBoxTreeItem = WebFXCheckBoxTreeItem;
	this.WebFXCheckBoxTreeItem(sText, bChecked, checkValue, sAction, eParent, sIcon, sOpenIcon);

	// setup default property values
	this.src = sXmlSrc;
	this.loading = false;
	this.loaded = false;
	this.errorText = "";

	// check start state and load if open
	if (this.open)
		_startLoadXmlTree_Checkbox(this.src, this);
	else {
		// and create loading item if not
		this._loadingItem = new WebFXCheckBoxTreeItem(webFXTreeConfig.loadingText);
		this.add(this._loadingItem);
	}
}

WebFXCheckBoxLoadTreeItem.prototype = new WebFXCheckBoxTreeItem;

// override the expand method to load the xml file
WebFXCheckBoxLoadTreeItem.prototype._webfxtreeitem_expand = WebFXCheckBoxTreeItem.prototype.expand;
WebFXCheckBoxLoadTreeItem.prototype.expand = function() {
	if (!this.loaded && !this.loading) {
		// load
		_startLoadXmlTree_Checkbox(this.src, this);
	}
	this._webfxtreeitem_expand();
};

// reloads the src file if already loaded
WebFXCheckBoxLoadTree.prototype.reload =
WebFXCheckBoxLoadTreeItem.prototype.reload = function () {
	// if loading do nothing
	if (this.loaded) {
		var open = this.open;
		// remove
		while (this.childNodes.length > 0)
			this.childNodes[this.childNodes.length - 1].remove();

		this.loaded = false;

		this._loadingItem = new WebFXCheckBoxTreeItem(webFXTreeConfig.loadingText);
		this.add(this._loadingItem);

		if (open)
			this.expand();
	}
	else if (this.open && !this.loading)
		_startLoadXmlTree_Checkbox(this.src, this);
};

/*
 * Helper functions
 */

// creates the xmlhttp object and starts the load of the xml document
function _startLoadXmlTree_Checkbox(sSrc, jsNode) {
	if(sSrc == null || sSrc == "")
		return;

	if (jsNode.loading || jsNode.loaded)
		return;
	jsNode.loading = true;
	var xmlHttp = XmlHttp.create();
	xmlHttp.open("POST", sSrc, true);	// async
	xmlHttp.onreadystatechange = function () {
		if (xmlHttp.readyState == 4) {
			_xmlFileLoaded_Checkbox(xmlHttp.responseXML, jsNode);
		}
	};

	// call in new thread to allow ui to update
	window.setTimeout(function () {
		xmlHttp.send(null);
	}, 10);
}


// Converts an xml tree to a js tree. See article about xml tree format
function _xmlTreeToJsTree_Checkbox(oNode) {
	// retreive attributes
	var text = oNode.getAttribute("text");
	var action = oNode.getAttribute("action");
	var parent = null;
	var icon = oNode.getAttribute("icon");
	var openIcon = oNode.getAttribute("openIcon");
	var src = oNode.getAttribute("src");
	var target = oNode.getAttribute("target");
	var checkValue = oNode.getAttribute("checkValue");
	var clickFunc = oNode.getAttribute("clickFunc");

	var bChecked = false;
	if(oNode.getAttribute("checked") == "true")
	{
		bChecked = true;
	}

	// create jsNode
	var jsNode;
	if (src != null && src != "")
		jsNode = new WebFXCheckBoxLoadTreeItem(text, bChecked, checkValue, src, action, parent, icon, openIcon);
	else
		jsNode = new WebFXCheckBoxTreeItem(text, bChecked, checkValue, action, parent, icon, openIcon);

	jsNode.clickFunc = clickFunc
	
	if (target != "")
		jsNode.target = target;

	// go through childNOdes
	var cs = oNode.childNodes;
	var l = cs.length;
	for (var i = 0; i < l; i++) {
		if (cs[i].tagName == "tree")
			jsNode.add( _xmlTreeToJsTree_Checkbox(cs[i]), true );
	}

	return jsNode;
}

// Inserts an xml document as a subtree to the provided node
function _xmlFileLoaded_Checkbox(oXmlDoc, jsParentNode) {
	if (jsParentNode.loaded)
		return;

	var bIndent = false;
	var bAnyChildren = false;
	jsParentNode.loaded = true;
	jsParentNode.loading = false;

	// check that the load of the xml file went well
	if( oXmlDoc == null || oXmlDoc.documentElement == null) {
		alert(oXmlDoc.xml);
		jsParentNode.errorText = parseTemplateString_Checkbox(webFXTreeConfig.loadErrorTextTemplate,
							jsParentNode.src);
	}
	else {
		// there is one extra level of tree elements
		var root = oXmlDoc.documentElement;

		// loop through all tree children
		var cs = root.childNodes;
		var l = cs.length;
		for (var i = 0; i < l; i++) {
			if (cs[i].tagName == "tree") {
				bAnyChildren = true;
				bIndent = true;
				jsParentNode.add( _xmlTreeToJsTree_Checkbox(cs[i]), true);
			}
		}

		// if no children we got an error
		if (!bAnyChildren)
			jsParentNode.errorText = parseTemplateString_Checkbox(webFXTreeConfig.emptyErrorTextTemplate,
										jsParentNode.src);
	}

	// remove dummy
	if (jsParentNode._loadingItem != null) {
		jsParentNode._loadingItem.remove();
		bIndent = true;
	}

    //设置是否选中
    setCheck();

	if (bIndent) {
		// indent now that all items are added
		jsParentNode.indent();
	}

	// show error in status bar
	if (jsParentNode.errorText != "")
		window.status = jsParentNode.errorText;
}

// parses a string and replaces %n% with argument nr n
function parseTemplateString_Checkbox(sTemplate) {
	var args = arguments;
	var s = sTemplate;

	s = s.replace(/\%\%/g, "%");

	for (var i = 1; i < args.length; i++)
		s = s.replace( new RegExp("\%" + i + "\%", "g"), args[i] )

	return s;
}







/*
  用于树的三态选择
  checkProperty　首先定义了一个对象，用来保存选择的状态，
　setCheckedTreeNode 方法用来初始化对象，并且设置子节点是否需要选中，如果需要的话则展开节点
  setCheck 回调函数，用于设置子节点是否需要选中，并且将对象checkProperty　恢复到缺省状态
*/
var checkProperty =
{
  /**
   * 被check的节点，WebFXCheckBoxLoadTree或WebFXCheckBoxLoadTreeItem类型
   */
  treeNode : null,

  /**
   * check的状态，boolean类型
   */
  bChecked : null,

  /**
   * check是否影响到下级直接节点，boolean类型
   */
  isContainChildren : null,

  /**
   * 本次check影响到的所有节点，WebFXCheckBoxLoadTree或WebFXCheckBoxLoadTreeItem为元素的数组
   */
  nodes : new Array()
};

/*
 * 选树点函数
 * treeNode 传入的要操作的树结点
 * bChecked boolean 选中还是不选中
 * isContainChildren 是否包含下级节点，是则将该结点及其下级结点全部选中，否则只选中该结点
 */
function setCheckedTreeNode(treeNodeID,bChecked,isContainChildren)
{
  checkProperty.treeNode = webFXTreeHandler.all[treeNodeID];
  checkProperty.bChecked = bChecked;
  checkProperty.isContainChildren = isContainChildren;

  //是否选中了节点
  if(checkProperty.treeNode != null)
  {
    //是否包含下级
    if(checkProperty.isContainChildren)
    {
      //是否叶子节点
      if(checkProperty.treeNode.src !=null && checkProperty.treeNode.src != "")
      {
        if(checkProperty.bChecked)
        {
          checkProperty.treeNode.expand();
        }

        childrenNode = checkProperty.treeNode.childNodes;
        for(i=0;i<childrenNode.length;i++)
        {
          child = childrenNode[i];
          child.setChecked(checkProperty.bChecked);
          //记录状态被设置（check或取消check）的节点（非虚拟节点）
          if(checkProperty.treeNode.loaded)
          {
              checkProperty.nodes[checkProperty.nodes.length] = child;
          }
        }
      }
    }
    checkProperty.treeNode.setChecked(bChecked);
    //记录状态被设置（check或取消check）的节点（非虚拟节点）
    checkProperty.nodes[checkProperty.nodes.length] = checkProperty.treeNode;
    //通知check操作已经完成
    afterCheck();
    if(checkProperty.treeNode.loaded)
    {
        clearCheckProperty();
    }
  }
}

function setCheck()
{
  if(checkProperty.treeNode != null && checkProperty.isContainChildren)
  {
    childrenNode = checkProperty.treeNode.childNodes;
    for(i=0;i<childrenNode.length;i++)
    {
      child = childrenNode[i];
      child.setChecked(checkProperty.bChecked);
      //记录状态被设置（check或取消check）的节点（非虚拟节点）
      checkProperty.nodes[checkProperty.nodes.length] = child;
    }
  }
  //通知check操作已经完成
  afterCheck();
  clearCheckProperty();
}

/**
 * 清空checkProperty对象
 */
function clearCheckProperty()
{
  checkProperty.isContainChildren = null;
  checkProperty.treeNode = null;
  checkProperty.bChecked = null;
  checkProperty.nodes = new Array()
}

/**
 * check操作完成后的回调函数，缺省什么都不做，用户可以定义新的afterCheck()覆盖之
 */
function afterCheck()
{
}