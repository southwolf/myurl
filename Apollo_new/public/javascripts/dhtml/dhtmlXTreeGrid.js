/*
Copyright Scand LLC http://www.scbr.com
This version of Software is free for using in GNU GPL applications. For other use or to get Professional Edition please contact info@scbr.com to obtain license
*/ 

/**
*	@desc: switch current row state (collapse/expand) tree grid row
*	@param: obj - row object
*	@type: private
*/
dhtmlXGridObject.prototype.doExpand=function(obj){  
    this.editStop();
	var row = obj.parentNode.parentNode.parentNode;
	var tbl = this.obj;
	var disp = "";
	if(obj.src.indexOf("plus")!=-1){
		this.expandKids(row,true)
	}else{
        if (!row._closeable)
    		this.collapseKids(row)
	}
}




/**
*	@desc: close row of treegrid (removes kids from dom)
*	@param: curRow - row to process kids of
*	@param: kidsAr - array where to store child rows. if exists, then rows added to it
*	@param: start - row to start processing from (only if 3 arguments)
*	@type: private
*/
dhtmlXGridObject.prototype.collapseKids=function(curRow,kidsAr,start){
    if (curRow.expand!="") return;
    if ((this._spnFH)&&(!this._spnFH(curRow.idd,1))) return;

	if(!start)
		start = curRow.rowIndex;

	if(!kidsAr){
		kidsAr = new Array(0)
		curRow.expand="none"
		treeCell = curRow.childNodes[this.cellType._dhx_find("tree")]
		treeCell.innerHTML = treeCell.innerHTML.replace(/\/minus\.gif/,"/plus.gif")
	}
	for(var i=start;i<this.obj._rowslength();i++){
		var row = this.obj._rows(i);
		if(row.parent_id==curRow.idd){
			if(row.expand=="")
				var add_fl = true
			else
				var add_fl = false
			kidsAr[kidsAr.length] = row.parentNode.removeChild(row);

			this.rowsCol._dhx_removeAt(i)
			if(add_fl)
				this.collapseKids(row,null,i)
			i--;
		}
	}

    if (this._ahgr) this.setSizes();



	this.loadedKidsHash.put(curRow.idd,kidsAr)
	if(arguments.length==1){
        if (this._epnFH) this._epnFH(curRow.idd,-1);
        }

	return kidsAr;
}


/**
*	@desc: change parent of row, correct kids collections
*	@param: r2 - moved row
*	@param: r1 - new parent row
*	@type: private
*/
        dhtmlXGridObject.prototype._changeParent=function(r2,r1){
            if (!r1){
               r2.parent_id=0;
                return;
            }
            if (r2.parent_id==r1.idd){
                var a=this.loadedKidsHash.get(r1.idd);
                var z=a._dhx_find(r2);
                a._dhx_removeAt(z);
                if (this._dhkPos){
                    if (this._dhkPos>z) this._dhkPos--;
                    a._dhx_insertAt(this._dhkPos,r2);
                }
                this.loadedKidsHash.put(r1.idd,a);
/*                for (var i=0; i<a.length; i++)
                    alert(a[i].idd);*/
                return;
            }
            var a=this.loadedKidsHash.get(r2.parent_id);
            var b=this.loadedKidsHash.get(r1.idd);
            if (!b) b=new Array();
            if (a){
                a._dhx_removeAt(a._dhx_find(r2));
                this.loadedKidsHash.put(r2.parent_id,a);
                }
            if (this._dhkPos){
                b._dhx_insertAt(this._dhkPos,r2);
                }
            else
                b._dhx_insertAt(0,r2);
            this.loadedKidsHash.put(r1.idd,b);

            r2.parent_id=r1.idd;
        }


/**
*	@desc: change parent of row, correct kids collections
*	@param: curRow - row to process
*	@type: private
*/
dhtmlXGridObject.prototype.expandKids=function(curRow){
    if ((curRow.has_kids==0)&&(!curRow._xml_await)) return;
    if (curRow.expand=="") return;
    if (!curRow._loading)
        if ((this._spnFH)&&(!this._spnFH(curRow.idd,-1))) return;

	var start = this.getRowIndex(curRow.idd)+1;
	var kidsAr = this.loadedKidsHash.get(curRow.idd);

	if(kidsAr!=null){
        curRow._loading=false;
    	curRow.expand = "";
    	treeCell = curRow.childNodes[this.cellType._dhx_find("tree")];
	    treeCell.innerHTML = treeCell.innerHTML.replace(/\/(plus|blank)\.gif/,"/minus.gif");

		for(var i=0;i<kidsAr.length;i++){
			//alert(kidsAr[i].outerHTML)
			var row = (!_isKHTML)?this.obj.childNodes[0].appendChild(kidsAr[i]):this.obj.appendChild(kidsAr[i]);

			if (this.obj._rows(start) && this.obj._rows(start)!=row )
                this.obj._rows(start).parentNode.insertBefore(row,this.obj._rows(start));
            //next line commented, because record already exists in  rowsCol array
			this.rowsCol._dhx_insertAt(start,row)
			start++;
		}
	    if(this.fldSorted!=null){
    		this.sortTreeRows(this._ls_col, this._ls_type, this._ls_order);
        if (this._epnFH) this._epnFH(curRow.idd,1);
    	}
	}else{
        if (curRow._xml_await){
		if(this.kidsXmlFile.indexOf("?")!=-1)
			var s = "&";
		else
			var s = "?";
        curRow._loading=true;
		this.loadXML(this.kidsXmlFile+""+s+"id="+curRow.idd);
        }
	}
    if ((this._ahgr)&&(!this._startXMLLoading)) this.setSizes();
    if (!curRow._loading)
    if (this._epnFH) this._epnFH(curRow.idd,1);
}

dhtmlXGridObject.prototype.kidsXmlFile = "";



/**
*	@desc: sorts treegrid by specified column
*	@param: col - column index
*	@param:	type - str.int.date
*	@param: order - asc.desc
*	@type: public
*   @edition: Professional
*	@topic: 2,3,5,9
*/
dhtmlXGridObject.prototype.sortTreeRows = function(col,type,order){
                    this._ls_col=col;
                    this._ls_type=type;
                    this._ls_order=order;

					var byParentHash = new Hashtable();
					for(var i=0;i<this.obj._rowslength();i++){
						if(byParentHash.get(this.obj._rows(i).parent_id)==null)
							byParentHash.put(this.obj._rows(i).parent_id,new Array());
					}
					for(var i=0;i<this.obj._rowslength();i++){
						var tmpAr = byParentHash.get(this.obj._rows(i).parent_id);
						tmpAr[tmpAr.length] = this.obj._rows(i).idd//i
						byParentHash.put(this.obj._rows(i).parent_id,tmpAr);
					}


					var keysAr = byParentHash.keys;
					for(var j=0;j<keysAr.length;j++){
						var tmpAr = byParentHash.get(keysAr[j]);
						var ar = new Array();
						for(var i=0;i<tmpAr.length;i++){
							ar[i] = new Array();

							var c = this.getRowById(tmpAr[i]).cells[col];
							eval("var ed = new eXcell_"+this.cellType[col]+"(c)");
							if(type=='int'){
								if(ed.getValue().toString()._dhx_trim()=="")
									ar[i][0] = -999999999
								else
									ar[i][0] = parseInt(ed.getValue().toString());
							}else
								ar[i][0] = ed.getValue().toString();

							ar[i][1] = this.getRowById(tmpAr[i])//obj.rows[tmpAr[i]];
                            if ((i!=0)&&(ar[i][0]!=ar[i-1][0])) ar._sort_me=true;
						}
                        // debugger;
                        if (ar._sort_me)
                        {
    					if(type=='str')
							ar.sort(function(a,b){return (a[0]<b[0]?-1:(a[0]==b[0]?0:1))})

						if(type=='int')
							ar.sort(function(a,b){return (a[0]<b[0]?-1:(a[0]==b[0]?0:1))})

						if(type=='date'){
							try{
								ar.sort(function(a,b){return Date.parse(new Date(a[0]))-Date.parse(new Date(b[0]))})
							}catch(er){
								alert('Incompatible date format.Sorted as string')
							    ar.sort(function(a,b){return (a[0]<b[0]?-1:(a[0]==b[0]?0:1))})
							}
						}
                        }


            //  debugger;

                if (!_isKHTML){
                    var tb = this.obj.childNodes[0];
                    var z=this.getRowById(keysAr[j]);
                    if (z) z=z.rowIndex+1;
                    }
                else{
                    var tb = this.obj._rows(0).parentNode;
                    var z=-1;
                    for (var zkk=0; zkk<this.obj._rowslength(); zkk++)
                        if (this.obj._rows(zkk).idd==keysAr[j])
                            { z=zkk+1; break; }
                    }



                if (z<1) 	var parentInd=0;
                else       	var parentInd=z-1;


						if ((order!='asc')&&(ar._sort_me))
							for(var i=0;i<ar.length;i++)                        {
                                if (tb.moveRow)
    								tb.moveRow(ar[i][1].rowIndex,parentInd+1)
                                else
                                   if (this.obj._rows(parentInd))
                                       {
                                       if (ar[i][1]!=this.obj._rows(parentInd))
                                       tb.insertBefore(ar[i][1],this.obj._rows(parentInd));
                                       }
                                   else
                                       tb.appendChild(ar[i][1]);                }

						else
						   	for(var i=ar.length-1;i>=0;i--)                      {
                                if (tb.moveRow)
        						   tb.moveRow(ar[i][1].rowIndex,parentInd+1) ;
                                else
                                   if (this.obj._rows(parentInd))
                                       {
                                       if (ar[i][1]!=this.obj._rows(parentInd))
                                       tb.insertBefore(ar[i][1],this.obj._rows(parentInd));
                                       }
                                   else
                                       tb.appendChild(ar[i][1]);                  }
					}


                    this.rowsCol=new Array();
                    for (var i=0; i<this.obj._rowslength(); i++)
                        this.rowsCol[i]=this.obj._rows(i);

					   //	this.setSizes();

					}

/**
*	@desc: correct kids collection after adding new row
*	@param: pRow - parent row
*	@type: private
*/
dhtmlXGridObject.prototype.has_kids_dec=function(pRow){
            if (!pRow) return;
            pRow.has_kids--;
            if (pRow.has_kids==0){
                    pRow.expand=null;
                	var treeCell = pRow.childNodes[this.cellType._dhx_find("tree")];
  		        	treeCell.innerHTML = treeCell.innerHTML.replace(/\/plus|minus\.gif/,"/blank.gif")
               }
            /*
            if (pRow._sumArr)
                for (var i=0; i<pRow.childNodes.length; i++)
                    if  (pRow.childNodes[i]._sumArr)
                        this.cells3(pRow,i).setValueA(this._calcSCL(i));*/
      }

/**
*	@desc: correct kids collection after removing new row
*	@param: pRow - parent row
*	@param: treeCell - index of tree column
*	@type: private
*/
dhtmlXGridObject.prototype.has_kids_inc=function(pRow,treeCell){
                if (!pRow) return;
                if ((!pRow.has_kids)||(pRow.has_kids==0)){
                    pRow.has_kids=1;
                    pRow.expand="no";
  			        pRow.childNodes[treeCell].innerHTML = pRow.childNodes[treeCell].innerHTML.replace(/\/blank\.gif/,"/plus.gif")
                    }
                else{
                    pRow.has_kids++;
                    }
//                alert(pRow.idd+"-"+pRow.has_kids);
        }



/**
*	@desc: TreeGrid cell constructor
*	@param: cell - cell object
*	@type: private
*/
function eXcell_tree(cell){
	try{
		this.cell = cell;
		this.grid = this.cell.parentNode.grid;
	}catch(er){}
	this.edit = function(){
        if ((this.er)||(this.grid._edtc)) return;
        this.er=this.cell.childNodes[0];
        this.er=this.er.childNodes[this.er.childNodes.length-1];
        this.val=this.er.innerHTML;
        this.er.innerHTML="<textarea class='dhx_combo_edit' type='text' style='height:"+(this.cell.offsetHeight-6)+"px; width:100%; border:0px; margin:0px; padding:0px; padding-top:"+(_isFF?1:2)+"px; overflow:hidden; font-size:12px; font-family:Arial;'></textarea>";
        if (_isFF)         this.er.style.top="1px";
        this.er.className+=" editable";
        this.er.firstChild.onclick = function(e){(e||event).cancelBubble = true};
        this.er.firstChild.value=this.val;
        this.er.firstChild.focus();
    }
	this.detach = function(){
        if (!this.er) return;
            this.er.innerHTML=this.er.firstChild.value;
            this.er.className=this.er.className.replace("editable","");
            var z=(this.val==this.er.innerHMTL);
            if (_isFF) this.er.style.top="2px";
            this.er=null;
        return (z);
    }
	this.getValue = function(){
		//alert(this.cell)
		var kidsColl = this.cell.childNodes[0].childNodes;
		for(var i=0;i<kidsColl.length;i++){
			//alert("value: "+kidsColl[i].tagName)
			if(kidsColl[i].id=='nodeval')
				return kidsColl[i].innerHTML;
		}
	}
    /**
    *	@desc: set label of treegrid item
    *	@param: content - new text of label
    *	@type: private
    */
	this.setValueA = function(content){
		//alert(this.cell)
		var kidsColl = this.cell.childNodes[0].childNodes;
		for(var i=0;i<kidsColl.length;i++){
			//alert("value: "+kidsColl[i].tagName)
			if(kidsColl[i].id=='nodeval')
				kidsColl[i].innerHTML=content;
		}
    }
    /**
    *	@desc: get image of treegrid item
    *	@param: content - new text of label
    *	@type: private
    */
	this.setImage = function(url){
		var z=this.cell.childNodes[0];
        var img=z.childNodes[z.childNodes.length-2];
        img.src=url;
	}

    /**
    *	@desc: set image of treegrid item
    *	@param: content - new text of label
    *	@type: private
    */
	this.getImage = function(){
		var z=this.cell.childNodes[0];
        var img=z.childNodes[z.childNodes.length-2];
        return img.src;
	}

	/**
	*	@desc: sets text representation of cell ( setLabel doesn't triger math calculations as setValue do)
	*	@param: val - new value
	*	@type: public
	*/
	this.setLabel = function(val){
						this.setValueA(val);
				}

    /**
    *	@desc: set value of grid item
    *	@param: val  - new value (for treegrid this method only used while adding new rows)
    *	@type: private
    */
	this.setValue = function(val){
					var valAr = val.split("^");//parent_id^Label^children^im0^im1^im2
					this.cell.parentNode.parent_id = valAr[0];
                    if (!this.grid.kidsXmlFile) valAr[2]=0;
                    else
                       this.cell.parentNode._xml_await=(valAr[2]!=0);

  					this.cell.parentNode.has_kids = valAr[2];

					//this.cell.parentNode._xml_wait = true;
					var pRow = this.grid.getRowById(valAr[0]);
					if(pRow==null){//check detached rows
						pRow = this.grid.loadedKidsHash.get("hashOfParents").get(valAr[0])
						//if(pRow!=null)
						//	alert(pRow+"::"+pRow.childNodes.length)
					}

					var preStr = "";//prenode html
					var node = "";//node html (two images and label)
					if(pRow!=null){//not zero level
						//alert(pRow.cells.length)

						var level = (pRow.childNodes[cell._cellIndex].firstChild.childNodes.length-1)-1
						for(var i=0;i<level;i++)
							preStr += "<span class='space'><img src='"+this.grid.imgURL+"/blanc.gif' height='1px' class='space'></span>"

                        this.grid.has_kids_inc(pRow,this.cell._cellIndex);

						//alert("aga")
						if(pRow.expand!=""){
							//this.cell.parentNode.style.display = "none"
							this.grid.doOnRowAdded = function(row){
										if(row.has_kids>0){
											var parentsHash = this.loadedKidsHash.get("hashOfParents")
											parentsHash.put(row.idd,row)
											this.loadedKidsHash.put("hashOfParents",parentsHash)
										}
										var kidsAr = this.loadedKidsHash.get(row.parent_id)
										if(kidsAr==null){
											var kidsAr = new Array(0)
										}

										kidsAr[kidsAr.length] = row.parentNode.removeChild(row);
                                        this.rowsCol._dhx_removeAt(this.rowsCol._dhx_find(row));
										this.loadedKidsHash.put(row.parent_id,kidsAr)
							}
						}else{
							this.grid.doOnRowAdded = function(row){}
							pRow.childNodes[this.cell._cellIndex].innerHTML = pRow.childNodes[this.cell._cellIndex].innerHTML.replace(/\/plus\.gif/,"/minus.gif")
                            var kidsAr = this.grid.loadedKidsHash.get(pRow.idd)

                            if (this._dhkPos)
                                kidsAr_dhx_insertAt(this._dhkPos,this.cell.parentNode);
                            else
                                kidsAr[kidsAr.length] = this.cell.parentNode;

                            this.grid.loadedKidsHash.put(pRow.idd,kidsAr)
						}

					}else{//zero level
						this.grid.doOnRowAdded = function(row){}
						preStr = "";
					}
					//if has children
				 	if(valAr[2]!="" && valAr[2]!=0)
						node+="<img src='"+this.grid.imgURL+"/plus.gif";
                    else
                        node+="<img src='"+this.grid.imgURL+"/blank.gif";
						node+="' align='absmiddle' onclick='this."+(_isKHTML?"":"parentNode.")+"parentNode.parentNode.parentNode.parentNode.grid.doExpand(this);event.cancelBubble=true;'>";
						//this.grid.collapseKids(this.cell.parentNode)


				   node+="<img src='"+this.grid.imgURL+"/"+valAr[3]+"' align='absmiddle' "+(this.grid._img_height?(" height=\""+this.grid._img_height+"\""):"")+(this.grid._img_width?(" width=\""+this.grid._img_width+"\""):"")+" >";
				   node+="<span "+(_isFF?"style='position:relative; top:2px;'":"")+"id='nodeval'>"+valAr[1]+"</span>"

                 /*   if (this.grid.multiLine)
    				    this.cell.innerHTML = "<div style=' overflow:hidden; '>"+preStr+""+node+"</div>";
                    else*/
                        this.cell.innerHTML = "<div style=' overflow:hidden; white-space : nowrap; height:20px;'>"+preStr+""+node+"</div>";

                    this.cell._aimage=valAr[3];
                    if (_isKHTML) this.cell.vAlign="top";
                    this.cell.parentNode.has_kids=0;
				}
	
}
eXcell_tree.prototype = new eXcell;

    /**
    *	@desc: correct visual representation of tree grid item  - initialisation part
    *	@param: r2  - row object
    *	@type: private
    */
dhtmlXGridObject.prototype._fixLevel=function(r2){
     var pRow=this.getRowById(r2.parent_id);

     var trcol=this.cellType._dhx_find("tree");

     this.has_kids_inc(pRow,trcol);

     if (pRow){
     pRow.childNodes[trcol].innerHTML = pRow.childNodes[trcol].innerHTML.replace(/\/plus\.gif/,"/minus.gif")
     pRow.expand = "";
     }

     var preStr="";
     if (!pRow) var level=0;
     else
  	 var level = (pRow.childNodes[trcol].firstChild.childNodes.length-1)-1;
	 for(var i=0;i<level;i++)
		 preStr += "<span class='space'><img src='' height='1' class='space'></span>"


    this._fixLevel2(r2,preStr,trcol);
        };

    /**
    *	@desc: correct visual representation of tree grid item - recursive part
    *	@param: r2  - row object
    *	@param: preStr  - string with corrected html
    *	@param: trcol  - index of treeGrid column
    *	@type: private
    */
dhtmlXGridObject.prototype._fixLevel2=function(r2,preStr,trcol){

     var z=r2.childNodes[trcol].firstChild.innerHTML;
     z=preStr+z.replace(/<(SPAN)[^>]*(><IMG)[^>]*(><\/SPAN>)/gi,"");
     r2.childNodes[trcol].firstChild.innerHTML=z;

     var a=this.loadedKidsHash.get(r2.idd);
     if (a){
     for (var i=0; i<a.length; i++)
         this._fixLevel2(a[i],preStr+"<span class='space'><img src='' height='1' class='space'></span>",trcol);
    this.loadedKidsHash.put(r2.idd,a);
    }

        };

    /**
    *	@desc: remove row from treegrid
    *	@param: node  - row object
    *	@type: private
    */
dhtmlXGridObject.prototype._removeTrGrRow=function(node){
			var parent_id = node.parent_id
			this.collapseKids(node)
            //not sure about purpose of logic below,
            //but seems that is works for only one level of inheritance
			var tmpAr = this.loadedKidsHash.get(parent_id)
			if(tmpAr!=null)
				tmpAr._dhx_removeAt(tmpAr._dhx_find(node))
			this.loadedKidsHash.remove(node.idd)
            //still not enough - must delete all child nodes as well
            var noda=node.nextSibling;
            this._removeTrGrRowRec(node.idd);

            pRow=this.getRowById(parent_id);
            if (!pRow) return;
            this.has_kids_dec(pRow);

		}

    /**
    *	@desc: remove child rows from treegrid
    *	@param: id  - parent row id
    *	@type: private
    */
dhtmlXGridObject.prototype._removeTrGrRowRec=function(id){
            //I think it relative slow
            //more than that, it based on
            var newa=new Array();
            for (var i=0; i<this.rowsCol.length; i++)
                if (id==this.rowsCol[i].parent_id)
                {
                    newa[newa.length]=this.rowsCol[i].idd;
                    this.rowsAr[this.rowsCol[i].idd] = null;
                    this.rowsCol._dhx_removeAt(i);
                    i--;
                }
            if (newa.length)
                for (var i=0; i<newa.length; newa++)
                    this._removeTrGrRowRec(newa[i]);
}


/**
*   @desc:  count rows inside branch
*   @type:  private
*/
dhtmlXGridObject.prototype._countBranchLength=function(ind){
    if (!this.rowsCol[ind+1]) return 1;
    if (this.rowsCol[ind+1].parent_id!=this.rowsCol[ind].idd) return 1;
    var count=1; var i=1;
    while   ((this.rowsCol[ind+count])&&(this.rowsCol[ind+count].parent_id==this.rowsCol[ind].idd)){
        count+=this._countBranchLength(ind+count);
        }
    return count;
}

/**
*	@desc: expand row
*	@param: rowId - id of row
*	@type:  public
*   @edition: Professional
*   @topic: 7
*/
dhtmlXGridObject.prototype.openItem=function(rowId){
        var x=this.getRowById(rowId);
        if (!x) return;
        this._openItem(x);
}


dhtmlXGridObject.prototype._openItem=function(x){
        var y=this.getRowById(x.parent_id);
        if (y)
            if (y.expand!="") this._openItem(y);
        this.expandKids(x);
}



dhtmlXGridObject.prototype._addRowClassic=dhtmlXGridObject.prototype.addRow;

    /**
    *	@desc: add new row to treeGrid
    *	@param: new_id  - new row id
    *	@param: text  - array of row label
    *	@param: ind  - position of row (set to null, for using parentId)
    *	@param: parent_id  - id of parent row
    *	@param: img  - img url for new row
    *	@param: child - child flag [optional]
    *	@type: public
    *   @edition: Professional
    */
dhtmlXGridObject.prototype.addRow=function(new_id,text,ind,parent_id,img,child){
     var trcol=this.cellType._dhx_find("tree");
     var last_row=null;
     if ((trcol!=-1)&&((text[trcol]||"").search(/\^/gi)==-1)){
        var def=text[trcol];
        var d=(parent_id||"0").toString().split(",");
        for (var i=0; i<d.length; i++){
            text[trcol]=d[i]+"^"+def+"^"+(child?1:0)+"^"+(img||"leaf.gif");
                if (d[i]!=0)
                if ((!ind)||(ind==0)){
                    ind=this.getRowIndex(d[i]);
					if (this.rowsCol[ind].expand=="") ind+=this._countBranchLength(ind);
                    }
              /*  var z=0;
                for (var i=0; i<this.rowsCol.length; i++)
                    z+="<div>"+this.rowsCol[i].idd+"</div>";
                document.getElementById("output_a").innerHTML=z;*/
            last_row=this._addRowClassic(new_id,text,((!parent_id)&&(!ind)&&(ind!="0"))?window.undefined:ind);
            }
        return last_row;
     }

     return this._addRowClassic(new_id,text,ind);

}





