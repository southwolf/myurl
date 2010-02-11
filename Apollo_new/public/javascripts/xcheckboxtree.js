/*
 *	Sub class that adds a check box in front of the tree item icon
 *
 *	Created by Erik Arvidsson (http://webfx.eae.net/contact.html#erik)
 *
 *	Disclaimer:	This is not any official WebFX component. It was created due to
 *				demand and is just a quick and dirty implementation. If you are
 *				interested in this functionality the contact us
 *				http://webfx.eae.net/contact.html
 *
 *	Notice that you'll need to add a css rule the sets the size of the input box.
 *	Something like this will do fairly good in both Moz and IE
 *
 *	input.tree-check-box {
 *		width:		auto;
 *		margin:		0;
 *		padding:	0;
 *		height:		14px;
 *		vertical-align:	middle;
 *	}
 *
 */

/*
 * WebFXCheckBoxTree class
 */

function WebFXCheckBoxTree(sText, bChecked, checkValue, sAction, sBehavior, sIcon, sOpenIcon) {
	this.base = WebFXTree;
	this.base(sText, sAction, sBehavior, sIcon, sOpenIcon);

	this._checked = bChecked;
	this._checkValue = checkValue;
}

WebFXCheckBoxTree.prototype = new WebFXTree;

WebFXCheckBoxTree.prototype.toString = function() {
	var str = "<div id=\"" + this.id + "\" ondblclick=\"webFXTreeHandler.toggle(this);\" class=\"webfx-tree-item\" onkeydown=\"return webFXTreeHandler.keydown(this, event)\">";

	// insert check box
	str += "<input type=\"checkbox\"" +
		" name=\"tree-check-box-name\"" +
        	" onClick=\"checkTreeNode('" + this.id + "',checked)\" " +
		" class=\"tree-check-box\"" +
		(this._checked ? " checked=\"checked\"" : "") +
		" value=\"" + this._checkValue + "\"" +
		" />";
	// end insert checkbox

	str += "<img id=\"" + this.id + "-icon\" class=\"webfx-tree-icon\" src=\"" + ((webFXTreeHandler.behavior == 'classic' && this.open)?this.openIcon:this.icon) + "\" onclick=\"webFXTreeHandler.select(this);\">" +
		"<a href=\"" + this.action + "\" id=\"" + this.id + "-anchor\" onfocus=\"webFXTreeHandler.focus(this);\" onblur=\"webFXTreeHandler.blur(this);\"" +
		(this.target ? " target=\"" + this.target + "\"" : "") +
		">" + this.text + "</a></div>" +
		"<div id=\"" + this.id + "-cont\" class=\"webfx-tree-container\" style=\"display: " + ((this.open)?'block':'none') + ";\">";
	var sb = [];
	for (var i = 0; i < this.childNodes.length; i++) {
		sb[i] = this.childNodes[i].toString(i, this.childNodes.length);
	}
	this.rendered = true;
	return str + sb.join("") + "</div>";
};

WebFXCheckBoxTree.prototype.setChecked = function (bChecked) {
	if (bChecked != this.getChecked()) {
		var divEl = document.getElementById(this.id);
		var inputEl = divEl.getElementsByTagName("INPUT")[0];
		this._checked = inputEl.checked = bChecked;

		if (typeof this.onchange == "function")
			this.onchange();
	}
};

/*
 * �õ����б�ѡ�е�checkboxֵ�����飬���û��ѡ�У�����lengthΪ0������
 */
WebFXCheckBoxTree.prototype.getCheckedValue = function() {

	var checkedValues = new Array();

	//this root node
	if(this.getChecked())
	{
		checkedValues = checkedValues.concat(this._checkValue);
	}

	//all chidren
	for(var i = 0; i < this.childNodes.length; i++)
	{
		checkedValues = checkedValues.concat(this.childNodes[i].getCheckedValue());
	}

	return checkedValues;
};

WebFXCheckBoxTree.prototype.getChecked = function () {
	var divEl = document.getElementById(this.id);
	var inputEl = divEl.getElementsByTagName("INPUT")[0];
	return this._checked = inputEl.checked;
};

WebFXCheckBoxTree.prototype.setChecked = function (bChecked) {
	if (bChecked != this.getChecked()) {
		var divEl = document.getElementById(this.id);
		var inputEl = divEl.getElementsByTagName("INPUT")[0];
		this._checked = inputEl.checked = bChecked;

		if (typeof this.onchange == "function")
			this.onchange();
	}
};

/*
 * WebFXCheckBoxTreeItem class
 */

function WebFXCheckBoxTreeItem(sText, bChecked, checkValue, sAction, eParent, sIcon, sOpenIcon) {
	this.base = WebFXTreeItem;
	this.base(sText, sAction, eParent, sIcon, sOpenIcon);

	this._checked = bChecked;
	this._checkValue = checkValue;
}

WebFXCheckBoxTreeItem.prototype = new WebFXTreeItem;

WebFXCheckBoxTreeItem.prototype.toString = function (nItem, nItemCount) {
	var foo = this.parentNode;
	var indent = '';
	if (nItem + 1 == nItemCount) { this.parentNode._last = true; }
	var i = 0;
	while (foo.parentNode) {
		foo = foo.parentNode;
		indent = "<img id=\"" + this.id + "-indent-" + i + "\" src=\"" + ((foo._last)?webFXTreeConfig.blankIcon:webFXTreeConfig.iIcon) + "\">" + indent;
		i++;
	}
	this._level = i;
	if (this.childNodes.length) { this.folder = 1; }
	else { this.open = false; }
	if ((this.folder) || (webFXTreeHandler.behavior != 'classic')) {
		if (!this.icon) { this.icon = webFXTreeConfig.folderIcon; }
		if (!this.openIcon) { this.openIcon = webFXTreeConfig.openFolderIcon; }
	}
	else if (!this.icon) { this.icon = webFXTreeConfig.fileIcon; }
	var label = this.text.replace(/</g, '&lt;').replace(/>/g, '&gt;');
	var str = "<div id=\"" + this.id + "\" ondblclick=\"webFXTreeHandler.toggle(this);\" class=\"webfx-tree-item\" onkeydown=\"return webFXTreeHandler.keydown(this, event)\">";
	str += indent;
	str += "<img id=\"" + this.id + "-plus\" src=\"" + ((this.folder)?((this.open)?((this.parentNode._last)?webFXTreeConfig.lMinusIcon:webFXTreeConfig.tMinusIcon):((this.parentNode._last)?webFXTreeConfig.lPlusIcon:webFXTreeConfig.tPlusIcon)):((this.parentNode._last)?webFXTreeConfig.lIcon:webFXTreeConfig.tIcon)) + "\" onclick=\"webFXTreeHandler.toggle(this);\">"

	// insert check box
	str += "<input type=\"checkbox\"" +
		" name=\"tree-check-box-name\"" +
        	" onClick=\"checkTreeNode('" + this.id + "',checked)\" " +
		" class=\"tree-check-box\"" +
		(this._checked ? " checked=\"checked\"" : "") +
		" value=\"" + this._checkValue + "\"" +
		" />";
	// end insert checkbox

	str += "<img id=\"" + this.id + "-icon\" class=\"webfx-tree-icon\" src=\"" + ((webFXTreeHandler.behavior == 'classic' && this.open)?this.openIcon:this.icon) + "\" onclick=\"webFXTreeHandler.select(this);\"><a href=\"" + this.action + "\" id=\"" + this.id + "-anchor\" onfocus=\"webFXTreeHandler.focus(this);\" onblur=\"webFXTreeHandler.blur(this);\">" + label + "</a></div>";
	str += "<div id=\"" + this.id + "-cont\" class=\"webfx-tree-container\" style=\"display: " + ((this.open)?'block':'none') + ";\">";
	for (var i = 0; i < this.childNodes.length; i++) {
		str += this.childNodes[i].toString(i,this.childNodes.length);
	}
	str += "</div>";
	this.plusIcon = ((this.parentNode._last)?webFXTreeConfig.lPlusIcon:webFXTreeConfig.tPlusIcon);
	this.minusIcon = ((this.parentNode._last)?webFXTreeConfig.lMinusIcon:webFXTreeConfig.tMinusIcon);
	return str;
}

WebFXCheckBoxTreeItem.prototype.getChecked = function () {
	var divEl = document.getElementById(this.id);
	var inputEl = divEl.getElementsByTagName("INPUT")[0];
	return this._checked = inputEl.checked;
};

WebFXCheckBoxTreeItem.prototype.setChecked = function (bChecked) {
	if (bChecked != this.getChecked()) {
		var divEl = document.getElementById(this.id);
		var inputEl = divEl.getElementsByTagName("INPUT")[0];
		this._checked = inputEl.checked = bChecked;

		if (typeof this.onchange == "function")
			this.onchange();
	}
};

/*
 * �õ����б�ѡ�е�checkboxֵ�����飬���û��ѡ�У�����lengthΪ0������
 */
WebFXCheckBoxTreeItem.prototype.getCheckedValue = function() {

	var checkedValues = new Array();

	//this root node
	if(this.getChecked())
	{
		checkedValues = checkedValues.concat(this._checkValue);
	}

	//all chidren
	for(var i = 0; i < this.childNodes.length; i++)
	{
		checkedValues = checkedValues.concat(this.childNodes[i].getCheckedValue());
	}

	return checkedValues;
};

/**
 * ���check boxʱ�����˷���������ȱʡʵ�֣�����jsp�����¶���÷���
 */
function checkTreeNode(nodeID, checked)
{
}