require "RegionValue"
require "FloatRegion"
require "RegionValueTree"
require "Size"
require "Const"
require "Table"
require "StyleManager"
require "ReportUtil"

class ReportResult
    def initialize(pDesignTable, fillType)
        @pDesignTable = pDesignTable
        @fillType = fillType
        @fixRegion = RegionValue.new(pDesignTable, CRect.new(0, 0, pDesignTable.GetColumnCount() - 1, pDesignTable.GetRowCount() - 1))
        @floatRegions = Array.new
        @regionValues = Hash.new
        
        if (fillType == FILL_VERTICAL)
            rowStart = 0
            Integer(0).upto(pDesignTable.GetColumnCount()-1) do |col|
                rowStart.upto(pDesignTable.GetRowCount()-1) do |row|
                    cell = pDesignTable.GetCell(row, col)
                    fill = pDesignTable.GetCellProperty(row, col, StyleManager::PROP_filltype)
                    if fill == fillType
                        pNewRegion = FloatRegion.new(pDesignTable, row, col, fillType)
                        @floatRegions<<pNewRegion
                        @regionValues[pNewRegion] = RegionValueTree.new(pNewRegion)
                        
                        row += cell.GetCoveredScale().y - 1
                        rowStart = row + 1
                    end
                end
            end
        elsif fillType == FILL_HORIZONTAL
            colStart = 0
            Integer(0).upto(pDesignTable.GetRowCount()-1) do |row|
                colStart.upto(pDesignTable.GetColumnCount()-1) do |col|
                    cell = pDesignTable.GetCell(row, col)
                    fill = pDesignTable.GetCellProperty(row, col, StyleManager::PROP_filltype)
                    if fill == fillType
                        pNewRegion = FloatRegion.new(pDesignTable, row, col, fillType)
                        @floatRegions<<pNewRegion
                        @regionValues[pNewRegion] = RegionValueTree.new(pNewRegion)
                        
                        col += cell.GetCoveredScale().x - 1;
                        colStart = col + 1
                    end
                end
            end
        end
    end
    
    def AppendValue(pTableValue)
        @fixRegion.AppendValue(pTableValue)
        
        Integer(0).upto(@floatRegions.length-1) do |i|
           pRegion = @floatRegions[i]
           rect = CRect.new(pRegion.GetRegionRect())
           key = pTableValue.GetCellValue(rect.top, rect.left)
           next if key == ""
           
           pRegionValueTree = @regionValues[pRegion]
           pRegionValue = pRegionValueTree.GetRegion(key)
           pRegion.AppendValue(pTableValue, pRegionValue)
        end
    end
    
    def CreateResultTable
        pTable = CTable.new(@pDesignTable.GetStyleManager(), @pDesignTable.GetTableID(), @pDesignTable.GetTableName())
        rectData = CRect.new(@pDesignTable.GetDataAreaRect())
        headRows = rectData.top
        headCols = rectData.left
        pTable.OnNewTable(GetTotalRows() - headRows, GetTotalColumns() - headCols, headRows, headCols)
        #if @pDesigntable.IsHeadFreezed()
        #    pTable.冻结表头
        #end
        mapRow2Region = Hash.new
        Integer(0).upto(@floatRegions.length - 1) do |i|
            pRegion = @floatRegions[i]
            if @fillType == FILL_VERTICAL
                mapRow2Region[pRegion.GetRegionRect().top] = pRegion
            else
                mapRow2Region[pRegion.GetRegionRect().left] = pRegion
            end
        end
        
        rowResult = 0
        rowCount = @pDesignTable.GetRowCount()
        if @fillType == FILL_HORIZONTAL
            rowCount = @pDesignTable.GetColumnCount()
        end
        
        #Integer(0).upto(rowCount-1) do |row|
        
        row = 0;
        while row < rowCount
            rectCopy = CRect.new(0,0,0,0)
            if @fillType == FILL_HORIZONTAL
               rectCopy.left = row
               rectCopy.top = 0
            else
                rectCopy.left = 0
                rectCopy.top = row
            end
            
            appendedRowsOrCols = 0
            if mapRow2Region.has_key?(row)
                pRegion = mapRow2Region[row]
                pRegionValueTree = @regionValues[pRegion]
                
                if @fillType == FILL_HORIZONTAL
                    rectCopy.right = pRegion.GetRegionRect().right
                    rectCopy.bottom = pRegion.GetRegionRect().top - 1
                else
                    rectCopy.right = pRegion.GetRegionRect().left - 1
                    rectCopy.bottom = pRegion.GetRegionRect().bottom
                end
                appendedRowsOrCols = pRegionValueTree.GetAppendedRowsOrCols()
            else
                pRegion = nil
                if @fillType == FILL_HORIZONTAL
                    rectCopy.right = row
                    rectCopy.bottom = @pDesignTable.GetRowCount() - 1
                else
                    rectCopy.right = @pDesignTable.GetColumnCount() - 1
                    rectCopy.bottom = row
                end
            end
            ReportUtil::CopyCellRegion(@pDesignTable, rectCopy, @fixRegion, pTable, rowResult, appendedRowsOrCols, @fillType)
            
            if pRegion
                rowResult = pRegionValueTree.FillTable(pTable, rowResult)
                if @fillType == FILL_HORIZONTAL
                    row += pRegion.GetRegionRect().Width()
                else
                    row += pRegion.GetRegionRect().Height()
                end
            else
                rowResult += 1
            end
            row += 1
        end
        
        pTable
    end
    
    def GetTotalColumns()
	cols= @pDesignTable.GetColumnCount()
	if(@fillType == FILL_HORIZONTAL)
	    cols += GetAppendedRowsOrCols()
	end
	cols
    end
    
    def GetTotalRows()
	rows= @pDesignTable.GetRowCount()
	if(@fillType == FILL_VERTICAL)
	    rows += GetAppendedRowsOrCols()
        end
	rows
    end
    
    def GetAppendedRowsOrCols
        count = 0
        @regionValues.each{|pRegion, pRegionValueTree|
            count += pRegionValueTree.GetAppendedRowsOrCols()
        }
        count
    end
    
        
    def GetCellMerge(pCell)
         flag= pCell.GetAttributes() & 0x00800000;
         flag = flag/0x00800000
         return flag == 0
    end
    
    def SetCellMerge(pCell, value)
	pCell.SetAttribute(0x00800000, !value);
    end
    
    def GetFillType
        @fillType
    end
end
