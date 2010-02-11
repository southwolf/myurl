var m_firstRow = -1;
var m_firstCol = -1;
	
//构造函数，传入一个table的element
function WebTable(element)
{
	this.m_tableElement = element;
	$A(element.getElementsByTagName('td')).each(
    	function(node)
    	{
        	if (node.expression)
        	{
        		
            	Event.observe(node, 'mousedown', cellMouseDown, true);
           	 	Event.observe(node, 'mousemove', cellMouseMove, false);
            	Event.observe(node, 'mouseup', cellMouseUp, true);
            	Event.observe(node, 'dblclick', cellDBClick, true);
            	Event.observe(node, 'keydown', cellKeyPress, true);
        	}
    	}
    );
}

//获得单元格所在列的序号，base 0
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

//获得单元格所在行的序号，base 0
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

//获得单元格所在表最大行号,base 0
WebTable.prototype.getMaxRow = function getMaxRow(element)
{
    var row = element.parentElement;
    var table = row.parentElement;
    return table.children.length-1;
}

//获得单元格所在表最大列号, base 0
WebTable.prototype.getMaxCol = function getMaxCol(element)
{
    var row = element.parentElement;
    return row.children.length-1
}

//根据行号列号获得单元格对象，base 0，element是任意一个单元格element,返回是一个dom element
WebTable.prototype.getCell = function getCell(element, row, col)
{
	if (row<0 || row > getMaxRow(element))
		return null;
		
	if (col<0 || col > getMaxCol(element))
		return null;
		
	return element.parentElement.parentElement.children[row].children[col];
}

//清空选择
WebTable.prototype.clearSelect = function clearSelect(tableElement)
{
  $A(tableElement.getElementsByTagName('td')).each(
    function(node)
    {
        if (node.expression)
        {
            node.style.backgroundColor = "white";
        }
    }
  );
}

//选择一个区域, ctrl：是否按下了ctrl键
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
            if (cellElement && cellElement.expression)
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
    
    activeTable = Event.element(event).parentElement.parentElement;
}

WebTable.prototype.cellMouseMove = function cellMouseMove(event)
{
    if (Event.isLeftClick(event) && m_firstRow > -1)  //按住了左键
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
	cell = Event.element(event);
	if (cell.tagName=='TD')
		createInput(cell, cell.innerText);
}

WebTable.createInput = function createInput(cell, value)
{
	if (cell.celltype == "date")
    {
        //cell.innerHTML = "<input  type=text onclick='getDateString(this,oCalendarChs)' style='border=0;height=100%; width=100%;margin:-1pt 0pt 0pt 0pt '/>";
        getDateString(cell, oCalendarChs);
        //text = cell.children[0];
        //text.value = value;
		//text.focus();
    }
    else if (cell.celltype == 'tree')
    {
    	div = $(cell.tree);
    	div.style.display = 'none'
    	//Element.show(div);
    	div.style.position = 'absolute';
    	div.style.left = cell.offsetLeft+2;
    	div.style.top = cell.offsetTop+cell.clientHeight;
    	div.cell = cell;
    	Effect.BlindDown(cell.tree);    	
    }
    else
    {
		cell.innerHTML = "<input type='text' style='BORDER-BOTTOM: solid 1px pink; BORDER-LEFT: solid 1px pink; BORDER-RIGHT: solid 1px pink; BORDER-TOP: solid 1px pink;height=100%; width=100%;margin:-1pt 0pt 0pt 0pt '></input>";
	
		text = cell.children[0];
		text.value = value;
		text.focus();
		text.select();
		if (value && value.length > 0)
		text.first_tag = true;
		text.onblur = cellBlur;
	}
	//Event.observe(text, 'blur', killInput, true);
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
		row = getRowIndex(cell)
    	col = getColumnIndex(cell)
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
		//数字型单元格
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
		//数字型单元格
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

