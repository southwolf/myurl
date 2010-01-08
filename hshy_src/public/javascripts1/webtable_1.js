var m_firstRow = -1;
var m_firstCol = -1;
	
	
function select_cellvalue(value, text, tree)
{	
    //Effect.BlindUp(tree);
    Element.hide(tree);
    var tree_element = $(tree);
    tree_element.cell.innerText = text;
    tree_element.cell.code_vlaue = value;
    tree_element.cell.focus();
}

function submit_webtable(objectname, form)
{
    table = $(objectname);
        
    $A(table.getElementsByTagName('td')).each(
    function(node)
    {
        if (node.expression && node.readonly!='true')
        {
            var n = $(node.expression.replace(/(\w+)\.(\w+)/, "$1_$2"))   //先删除
            if (n)        //如果有就先删除
                n.removeNode(true);   

            var oInput =document.createElement("input");
            oInput.type = "hidden";
            oInput.id = node.expression.replace(/(\w+)\.(\w+)/, "$1_$2");
            oInput.name = node.expression.replace(/(\w+)\.(\w+)/, "$1[$2]");
            if (node.code_value)
            {
                oInput.value = node.code_value;
            }  
            else                            
                oInput.value = node.innerText;
            form.appendChild(oInput);
        }
      }
    );
   
    if(typeof(audit) != 'undefined')
       return audit();
	
//    form.appendChild(oInput);
}

function WebTable(element)
{
    this.m_tableElement = element;
    
    $A(element.getElementsByTagName('td')).each(
    function(node)
    {
        if (node.getAttribute("expression") && node.getAttribute("readonly")!='true')
        {
            var n = Element.extend(node);
            
            if (Prototype.Browser.IE)
            {
                Event.observe(n, 'mousedown', cellMouseDown, true);
                Event.observe(n, 'mousemove', cellMouseMove, false);
                Event.observe(n, 'mouseup', cellMouseUp, true);
                Event.observe(n, 'dblclick', cellDBClick, true);
                Event.observe(n, 'keydown', cellKeyPress, true);
            }
            else
            {
                n.onmousedown = WebTable.cellMouseDown;
                n.onmousemove = WebTable.cellMouseMove;
                n.onmouseup = WebTable.cellMouseUp;
                n.ondblclick = WebTable.cellDBClick;
                n.onkeydown = WebTable.cellKeyPress;
            }
        }
    }
);
}

WebTable.prototype.getColumnIndex = function getColumnIndex(element)
{
    var parent = element.parentElement;
    for(var i=0; i<parent.children.length; i++)
    {
        if (parent.children[i] == element)
            return i;
    }
   
    return -1;
}

WebTable.prototype.getRowIndex = function getRowIndex(element)
{
    var row = element.parentElement;
    var table = row.parentElement;
    for(var i=0; i<table.children.length; i++)
    {
        if (table.children[i] == row)
            return i;
    }
   
    return -1;
}

WebTable.prototype.getMaxRow = function getMaxRow(element)
{
    var row = element.parentElement;
    var table = row.parentElement;
    return table.children.length-1;
}

WebTable.prototype.getMaxCol = function getMaxCol(element)
{
    var row = element.parentElement;
    return row.children.length-1
}

WebTable.prototype.getCell = function getCell(element, row, col)
{
    if (row<0 || row > getMaxRow(element))
        return null;
		
    if (col<0 || col > getMaxCol(element))
        return null;
		
    return element.parentElement.parentElement.children[row].children[col];
}


WebTable.prototype.clearSelect = function clearSelect(tableElement)
{
    $A(tableElement.getElementsByTagName('td')).each(
    function(node)
    {
        if (node.expression && node.readonly!='true')
        {
            node.style.backgroundColor = "white";
        }
    }
);
}

WebTable.prototype.selectCells = function selectCells(ctrl, tableElement, row1, col1, row2, col2)
{
    //var tableElement = Event.element(event).parentElement.parentElement;
    if (row1>row2)
    {
        var temp = row1;
        row1 = row2;
        row2 = temp;
    }
    
    if (col1>col2)
    {
        var temp = col1;
        col1 = col2;
        col2 = temp;
    }
  
    if (!ctrl)
        clearSelect(tableElement);
        
    for(var row=row1; row<=row2; row++)
    {
        var rowElement = tableElement.children[row];
        for(var col=col1; col<=col2; col++)
        {
            cellElement = rowElement.children[col]
            if (cellElement && cellElement.expression && cellElement.readonly!='true')
                cellElement.style.backgroundColor = "#ffcccc";
        }
    }
}

WebTable.prototype.cellMouseDown = function cellMouseDown(event)
{
    if (event.button!=1)
        return;
    m_firstRow = getRowIndex(Event.element(event));
    m_firstCol = getColumnIndex(Event.element(event));
    selectCells(event.ctrlKey, Event.element(event).parentElement.parentElement, m_firstRow, m_firstCol, m_firstRow, m_firstCol);
    
    var activeTable = Event.element(event).parentElement.parentElement;
}

WebTable.prototype.cellMouseMove = function cellMouseMove(event)
{
    if (Event.isLeftClick(event) && m_firstRow > -1)  //????????
    {
        selectCells(event.ctrlKey, Event.element(event).parentElement.parentElement, 
        m_firstRow, 
        m_firstCol, 
        getRowIndex(Event.element(event)), 
        getColumnIndex(Event.element(event)));
        event.returnValue = false;
    }
}

WebTable.prototype.cellMouseUp = function cellMouseUp(event)
{
    m_firstRow = -1;
    m_firstCol = -1;
}

WebTable.cellDBClick = function cellDBClick(event)
{
    var cell = Event.element(event);
    if (cell.tagName=='TD')
    {
        if(Prototype.Browser.IE)
          createInput(cell, cell.innerText);
        else
          createInput(cell, cell.textContent);
    }    
}


WebTable.cellBlur = function cellBlur()
{
    Input = window.event.srcElement;
    Input.parentElement.innerText = Input.value;
    Input.style.display = 'none';
}

WebTable.prototype.cellKeyPress = function cellKeyPress(event)
{
    cell = Event.element(event);
    if (cell.tagName == 'INPUT')
    {
        text = cell;
        cell = cell.parentElement;
        table = cell.parentElement.parentElement
        var row = getRowIndex(cell)
    	var col = getColumnIndex(cell)
        if (event.keyCode == Event.KEY_RETURN || event.keyCode == Event.KEY_DOWN)
        {			
            newcell = getCell(cell, row+1, col);
            if (row <getMaxRow(cell) && newcell && newcell.expression)
            {
                text.onblur();
                selectCells(false, table, row+1, col, row+1, col);
                createInput(newcell, newcell.innerText);
            }
        }
        if (event.keyCode == Event.KEY_UP)
        {			
            newcell = getCell(cell, row-1, col);
            if (row >0 && newcell && newcell.expression)
            {
                text.onblur();
                selectCells(false, table, row-1, col, row-1, col);	        	
                createInput(newcell, newcell.innerText);
            }
        }
        if (event.keyCode == Event.KEY_RIGHT)
        {			
            newcell = getCell(cell, row, col+1);
            if (row >0 && newcell && newcell.expression)
            {
                if (!text.first_tag)
                {
                    text.onblur();
                    selectCells(false, table, row, col+1, row, col+1);
                    createInput(newcell, newcell.innerText);
                }
                else
                {
                    text.first_tag = false;
                }
            }
            return true;
        }
        if (event.keyCode == Event.KEY_LEFT)
        {			
            newcell = getCell(cell, row, col-1);
            if (row >0 && newcell && newcell.expression)
            {
                text.onblur();
                selectCells(false, table, row, col-1, row, col-1);	        	
                createInput(newcell, newcell.innerText);
            }
        }
        //??????????
        if (cell.celltype != "text" && cell.celltype != "date" && cell.celltype != "tree")
        {
            if((event.keyCode>=48&&event.keyCode<=57) || event.keyCode==189 || event.keyCode ==190 || event.keyCode ==8)
            {
            }
            else
                return false;
        }
    }
    else if(cell.tagName == 'TD')
    {
        //??????????
        if (cell.celltype != "text" && cell.celltype != "date" && cell.celltype != "tree")
        {
            if((event.keyCode>=48&&event.keyCode<=57) || event.keyCode==189 || event.keyCode ==190 || event.keyCode ==8 || event.keyCode ==Event.KEY_LEFT || event.keyCode ==Event.KEY_RIGHT || event.keyCode ==Event.KEY_UP || event.keyCode ==Event.KEY_DOWN || event.keyCode ==Event.KEY_RETURN)
            {
            }
            else
                return false;
        }
        row = getRowIndex(cell)
    	col = getColumnIndex(cell)
    	table = Event.element(event).parentElement.parentElement
    	if (event.keyCode == Event.KEY_RIGHT)
        {    	
            if (col < getMaxCol(cell) && getCell(cell, row, col+1) && getCell(cell, row, col+1).expression)
            {
                selectCells(event.ctrlKey, table, row, col+1, row, col+1);
                getCell(cell, row, col+1).focus();
            }
        }
        else if (event.keyCode == Event.KEY_LEFT)
        {
            if (col >0 && getCell(cell, row, col-1) && getCell(cell, row, col-1).expression)
            {
                selectCells(event.ctrlKey, table, row, col-1, row, col-1);
                getCell(cell, row, col-1).focus();
            }
        }
        else if (event.keyCode == Event.KEY_UP)
        {
            if (row >0 && getCell(cell, row-1, col) && getCell(cell, row-1, col).expression)
            {
                selectCells(event.ctrlKey, table, row-1, col, row-1, col);
                getCell(cell, row-1, col).focus();
                return false;
            }
        }	
        else if (event.keyCode == Event.KEY_DOWN || event.keyCode == Event.KEY_RETURN)
        {
            if (row <getMaxRow(cell) && getCell(cell, row+1, col) && getCell(cell, row+1, col).expression)
            {
                selectCells(event.ctrlKey, table, row+1, col, row+1, col);
                getCell(cell, row+1, col).focus();
                return false;
            }
        }
        else
        {
            if (cell.children.length <= 0 && cell.tagName == 'TD')
            {
                createInput(cell, '');
            }
        }
    }
}


function createInput(cell, value)
{
    if (cell.readAttribute("celltype") == "date")
    {
        //cell.innerHTML = "<input  type=text onclick='getDateString(this,oCalendarChs)' style='border=0;height=100%; width=100%;margin:-1pt 0pt 0pt 0pt '/>";
        getDateString(cell, oCalendarChs);
        //text = cell.children[0];
        //text.value = value;
        //text.focus();
    }
    else if (cell.readAttribute("celltype") == 'tree')
    {
    	var div = $(cell.tree);
    	//div.style.display = 'none'
    	Element.show(div);
    	div.style.position = 'absolute';
    	div.style.left = cell.offsetLeft+2;
    	div.style.top = cell.offsetTop+cell.clientHeight;
    	div.cell = cell;
    	//Effect.BlindDown(cell.tree);    	
    }
    else
    {
        if (cell.offsetHeight < 50)
          cell.innerHTML = "<input type='text' class='required' style='BORDER-BOTTOM: solid 1px pink; BORDER-LEFT: solid 1px pink; BORDER-RIGHT: solid 1px pink; BORDER-TOP: solid 1px pink;height=100%; width=100%;margin:-1pt 0pt 0pt 0pt '></input>";
	else
          cell.innerHTML = "<textarea type='text' class='required' style='BORDER-BOTTOM: solid 1px pink; BORDER-LEFT: solid 1px pink; BORDER-RIGHT: solid 1px pink; BORDER-TOP: solid 1px pink;height=100%; width=100%;margin:-1pt 0pt 0pt 0pt '></input>";
        text = cell.children[0];
        text.value = value;
        text.focus();
        text.select();
        if (value && value.length > 0)
            text.first_tag = true;
        text.onblur = cellBlur;
    }
}
