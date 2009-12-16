require "Const"
require "CellValue"
require "Size"
require "ReportUtil"

class RegionValue    
    attr_reader :values
    
    def initialize(*args)
        if args.length == 1 #FloatRegion
            table = args[0].GetDesignTable()
            rect = args[0].GetRegionRect()
            @pRegion = args[0]
        elsif args.length == 2 #table, rect
            rect = args[1]
            table = args[0]
            @pRegion = nil
        end
        
        @values = Array.new
        
        colCount = rect.Width() + 1
        (rect.top).upto(rect.bottom) do |row|
           (rect.left).upto(rect.right) do |col|
               cell = table.GetCell(row, col)
               if cell.IsStore() && cell.IsEffective()
                   index = (row-rect.top) * colCount + (col - rect.left)
                   if cell.IsNumeric
                       valueType = DOUBLE
                   else
                       valueType = STRING
                   end
                   aggType= ReportUtil::GetCellAggregate(cell);
                   
                   @values<<CellValue.new(valueType, aggType)
               else
                   @values<<nil
               end
            end
        end
        
        @rectRegion = rect
        @pDesignTable = table  
        @childRegions = Hash.new
    end
    
    def AppendValue(table)
        index = 0
        (@rectRegion.top).upto(@rectRegion.bottom) do |row|
           (@rectRegion.left).upto(@rectRegion.right) do |col| 
                pValue = @values[index]
                index += 1
                if (pValue)
                    pValue.AppendValue(table.GetCellValue(row, col))
                end
            
            end
        end
    end
    
    def GetValue(row, col)
        colCount = @rectRegion.Width() + 1
        index = (row-@rectRegion.top)*colCount + (col - @rectRegion.left)
        pValue = @values[index]
        if pValue
            return pValue.GetValue().to_s
        else
            return ""
        end
    end
    
    def GetChildRegion(pRegion, key)
        @childRegions[pRegion] = Hash.new if !@childRegions.has_key?(pRegion)
        childRegionValues = @childRegions[pRegion]
        
        childRegionValues[key] = RegionValue.new(pRegion) if !childRegionValues.has_key?(key)
        
        childRegionValues[key]
    end
    
    def GetAppendedRowsOrCols
        count = GetRegionRowsOrCols()
        
        if (@pRegion.GetFillType() == FILL_HORIZONTAL)
            count -= @pRegion.GetRegionRect().Width() + 1
        else
            count -= @pRegion.GetRegionRect().Height() + 1
        end
        
        count
    end
    
    def GetRegionRowsOrCols
        count = 0
        @childRegions.each{|key, value|
            pRegion = key
            regionValues = value
            regionValues.each{|key2, value2|
                childRegionValue = value2
                count += childRegionValue.GetRegionRowsOrCols();            
            }
            if (regionValues.length >= 1)
                if pRegion.GetFillType() == FILL_HORIZONTAL
                    count -= pRegion.GetRegionRect.Width() + 1
                else
                    count -= pRegion.GetRegionRect.Height() + 1
                end
            end
        }
        
        if @pRegion.GetFillType() == FILL_HORIZONTAL
            count += @pRegion.GetRegionRect().Width() + 1
        else
            count += @pRegion.GetRegionRect().Height() + 1
        end
        
        return count
        
    end
    
    def FillTable(table, pRowOrColBegin)
        fillType = @pRegion.GetFillType
        
        cell = table.GetCell(@rectRegion.top, @rectRegion.left)
        rectCopy = CRect.new(@rectRegion)
        if @pRegion.GetFillType() == FILL_VERTICAL
            rectCopy.right = rectCopy.left + cell.GetCoveredScale().x - 1
        else
            rectCopy.bottom = rectCopy.top + cell.GetCoveredScale().y - 1;
        end
        
        appendedRowsOrCols = GetAppendedRowsOrCols()
        ReportUtil::CopyCellRegion(@pDesignTable, rectCopy, self, table, pRowOrColBegin, appendedRowsOrCols, fillType)
        mapRow2Region = Hash.new
        @childRegions.each{|pRegion, m|
            if fillType == FILL_VERTICAL
                mapRow2Region[pRegion.GetRegionRect().top()] = pRegion
            else
                mapRow2Region[pRegion.GetRegionRect().left()] = pRegion
            end
        }
        if fillType == FILL_VERTICAL
            rectCopy.left = rectCopy.right + 1
            beginRow = @rectRegion.top
            endRow = @rectRegion.bottom
        else
            rectCopy.top = rectCopy.bottom + 1
            beginRow = @rectRegion.left
            endRow = @rectRegion.right
        end
        
        #beginRow.upto(endRow) do |row|
        
        row = beginRow
        while row <= endRow
            if @pRegion.GetFillType() == FILL_VERTICAL
                rectCopy.top = row
            else
                rectCopy.left = row
            end
            if mapRow2Region.has_key?(row)
                pRegion = mapRow2Region[row]
                if @pRegion.GetFillType == FILL_VERTICAL
                    rectCopy.right = pRegion.GetRegionRect().left - 1
                    rectCopy.bottom = pRegion.GetRegionRect().bottom
                else
                    rectCopy.right = pRegion.GetRegionRect().right
                    rectCopy.bottom = pRegion.GetRegionRect().top - 1
                end
                appendedRowsOrCols = GetRegionAppendedRowsOrCols(pRegion)
            else
                pRegion = nil
                if (@pRegion.GetFillType() == FILL_VERTICAL)
                    rectCopy.right = @pDesignTable.GetColumnCount() - 1;
                    rectCopy.bottom = row
                else
                    rectCopy.right = row
                    rectCopy.bottom = @pDesignTable.GetRowCount() - 1;
                end
                appendedRowsOrCols = 0
            end
            
            ReportUtil::CopyCellRegion(@pDesignTable, rectCopy, self, table, pRowOrColBegin, appendedRowsOrCols, fillType)
            
            if pRegion
                pRegionValues = @childRegions[pRegion]
                keys = Array.new
                pRegionValues.each { |key, child|
                    if child.values[0].GetType() == DOUBLE
                    keys << key.to_i
                else
                    keys << key
                end
                }
                keys = keys.sort
                for key in keys
                    pRowOrColBegin = pRegionValues[key].FillTable(table, pRowOrColBegin)
                end
                
                if fillType == FILL_VERTICAL
                    row += pRegion.GetRegionRect().Height()
                else
                    row += pRegion.GetRegionRect().Width()
                end
            else
                if (fillType == FILL_VERTICAL)
                    pRowOrColBegin += rectCopy.Height() + 1
                else
                    pRowOrColBegin += rectCopy.Width() + 1
                end
            end
            row += 1
        end
        
        return pRowOrColBegin
    end
    
    def GetRegionAppendedRowsOrCols(pRegion)
        count = 0
        pRegionValues = @childRegions[pRegion]
        pRegionValues.each {|key, pChildRegionValue|
            count += pChildRegionValue.GetRegionRowsOrCols();
        }
        
        if pRegionValues.length > 1
            if pRegion.GetFillType() == FILL_HORIZONTAL
                count -= pRegion.GetRegionRect().Width() + 1
            else
                count -= pRegion.GetRegionRect().Height() + 1
            end
        end
        
        count
    end
end
