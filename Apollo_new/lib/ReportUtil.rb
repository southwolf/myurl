class ReportUtil 
    class <<self
        def GetCellMerge(pCell)
             flag= pCell.GetAttributes() & 0x00800000;
             flag = flag >> 23
             return flag == 0
        end
        
        def SetCellMerge(pCell, value)
            pCell.SetAttribute(0x00800000, !value);
        end
        
        def GetCellAggregate(pCell)
            flag= pCell.GetAttributes() & 0x007C0000;
            value= flag  << 18
            if(value<AGG_SUM || value>AGG_LAST_VALUE)
                    return AGG_SUM;
            end
            return value;
        end
    
        def SetCellAggregate(pCell, value)
            pCell.SetAttribute(0x007C0000, false);
    
            dwFlag= value >> 18
            pCell.SetAttribute(dwFlag, TRUE);
        end
        
        def GetCellFill(pCell)
            if(pCell.IsEffective() && pCell.IsStore())
                flag= pCell.GetAttributes() & 0x00030000;
                value= flag >> 16
                return FILL_NONE if(value<0 || value>FILL_VERTICAL)
                return value;
            else
                return FILL_NONE
            end
        end
        
        def SetCellFill(pCell, value)
            pCell.SetAttribute(0x00030000, false);
    
            dwFlag= value << 16
            pCell.SetAttribute(dwFlag, true);
        end
        
        def CopyCellRegion(pDesignTable, rectRegion, pRegionValue, pResultTable, destRowOrCol, rowsOrColsAppended, fillType)
            return if rectRegion.bottom<rectRegion.top || rectRegion.right < rectRegion.left
            
            #print "CopyCellRegion : l:#{rectRegion.left}, t:#{rectRegion.top}, r:#{rectRegion.right}, b:#{rectRegion.bottom}"
            
            if fillType == FILL_VERTICAL || fillType == FILL_NONE
                currentRowResult = destRowOrCol
                (rectRegion.top).upto(rectRegion.bottom) do |row|                    
                    pResultTable.SetRowHeight(currentRowResult, pDesignTable.GetRowHeight(row))
                    pResultTable.SetRowHidden(currentRowResult, pDesignTable.IsRowHidden(row))
                    
                    (rectRegion.left).upto(rectRegion.right) do |col|
                       pResultTable.SetColWidth(col, pDesignTable.GetColWidth(col))
                       #print "col: #{col}\n"
                       pResultTable.SetColHidden(col, pDesignTable.IsColHidden(col))
                       
                       pCellDesign = pDesignTable.GetCell(row, col)
                       pCellResult = pResultTable.GetCell(currentRowResult, col)
                       if !pCellDesign
                           pCellDesign = nil
                       end
                       pCellResult.copy(pCellDesign)
                       pCellResult.SetStyle(pCellDesign.GetStyle())
                       
                        if pCellDesign.IsEffective()
                            if pCellDesign.IsStore()
                               if pRegionValue
                                   pResultTable.SetCellValue(currentRowResult, col, pRegionValue.GetValue(row, col))
                               else
                                   pResultTable.SetCellValue(currentRowResult, col, "");
                               end
                            else
                                pResultTable.SetCellValue(currentRowResult, col, pDesignTable.GetCellValue(row, col))
                            end
                        end
                        
                        if row == rectRegion.top
                            ptCellMerge = pDesignTable.GetMappingBox(CPoint.new(col, row));
                            pCellMerge = pDesignTable.GetCell(ptCellMerge.y, ptCellMerge.x)
                            bMerge = GetCellMerge(pCellMerge)
                            1.upto(rowsOrColsAppended) do |i|
                                row1 = currentRowResult + i
                                break if row1 >= pResultTable.GetRowCount()
                                pCell = pResultTable.GetCell(row1, col)
                                if bMerge
                                    pCell.SetAttribute(TC_CF_EFFECTIVE, false)
                                    pCell.SetMappingBox(CSize.new(col-rectRegion.left, i))
                                    
                                else
                                    cell = pResultTable.GetCell(currentRowResult, col)
                                    pCell = cell
                                end
                            end
                            
                            if (bMerge && pCellDesign.IsEffective)
                                szCover = pCellDesign.GetCoveredScale()
                                newsize = CSize.new(szCover.cx, szCover.cy + rowsOrColsAppended)
                                #y = rowsOrColsAppended + szCover.cy
                                pCellResult.SetCoveredScale(newsize)
                                #print "MappingBox #{szCover.cy} -- #{szCover.cx}\n"
                            end
                        end
                    end
                    if row == rectRegion.top
                        currentRowResult += rowsOrColsAppended
                    end
                    currentRowResult += 1
                end
            else #FILL_HORIZONTAL
                currentColResult = destRowOrCol
                (rectRegion.left).upto(rectRegion.right) do |col|
                   pResultTable.SetColWidth(currentColResult, pDesignTable.GetColWidth(col))
                   pResultTable.SetColHidden(currentColResult, pDesignTable.IsColHidden(col))
                   
                    (rectRegion.top).upto(rectRegion.bottom) do |row|
                        pResultTable.SetRowHeight(row, pDesignTable.GetRowHeight(row))
                        pResultTable.SetRowHidden(row, pDesignTable.IsRowHidden(row))
                        
                        pCellDesign = pDesignTable.GetCell(row, col)
                        pCellResult = pResultTable.GetCell(row, currentColResult);
                        pCellResult.copy(pCellDesign)
                        
                        if pCellDesign.IsEffective()
                            if pCellDesign.IsStore()
                                if pRegionValue
                                    pResultTable.SetCellValue(row, currentColResult, pRegionValue.GetValue(row, col))
                                else
                                    pResultTable.SetCellValue(row, currentColResult, "")
                                end
                            else
                                pResultTable.SetCellValue(row, currentColResult, pDesignTable.GetCellValue(row, col))
                            end
                        end
                        
                        if col == rectRegion.left
                            ptCellMerge = pDesignTable.GetMappingBox(CPoint.new(col, row))
                            pCellMerge = pDesignTable.GetCell(ptCellMerge.y, ptCellMerge.x)
                            
                            bMerge = GetCellMerge(pCellMerge)
                            1.upto(rowsOrColsAppended) do |i|
                                pCell = pResultTable.GetCell(row, currentColResult+i)
                                if bMerge
                                    pCell.SetAttribute(TC_CF_EFFECTIVE, false)
                                    pCell.SetMappingBox(CSize.new(i, row-rectRegion.top))
                                else
                                    pCell = pCellDesign
                                end
                            end
                            
                            if bMerge && pCellDesign.IsEffective()
                                szCover = pCellDesign.GetCoveredScale
                                newsize = CSize(szCover.cx + rowsOrColsAppended, szCover.cy)
                                #szCover.cx += rowsOrColsAppended
                                pCellResult.SetCoveredScale(newsize)
                            end
                        end
                    end
                    if col == rectRegion.left
                        currentColResult += rowsOrColsAppended
                    end
                    currentColResult += 1
                end
            end
        end
    end
end
