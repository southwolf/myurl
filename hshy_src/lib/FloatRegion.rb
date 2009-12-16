require "Table"
require "Size"
require "Const"
require "StyleManager"

class FloatRegion
    attr_reader :fillType, :rect, :table
    
    def initialize(table, row, col, fillType)
        @childRegion = Array.new()
        @fillType = fillType
        @rect = CRect.new(col, row, -1, -1)
        @table = table
        cell = table.GetCell(row, col)
        if fillType == FILL_HORIZONTAL
            @rect.right = col + cell.GetCoveredScale().x - 1
            @rect.bottom = table.GetRowCount() -1
            
            colInnerStart = col
            (row+1).upto(@rect.bottom) do |rowInner|
                colInnerStart.upto(@rect.right) do |colInner|
                   fill = table.GetCellProperty(rowInner, colInner, StyleManager::PROP_filltype)
                   if fill == fillType
                       pNewRegion = FloatRegion.new(table, rowInner, colInner, fillType)
                       @childRegion<<pNewRegion
                       
                       colInner += cell.GetCoveredScale.x - 1
                       colInnerStart = colInner + 1
                   end
                end
            end
        else
            @rect.right = table.GetColumnCount() - 1
            @rect.bottom = row + cell.GetCoveredScale().y - 1
            
            rowInnerStart = row
            (col+1).upto(@rect.right) do |colInner|
                rowInnerStart.upto(@rect.bottom) do |rowInner|
                   fill = table.GetCellProperty(rowInner, colInner, StyleManager::PROP_filltype)
                   if fill == fillType
                       pNewRegion = FloatRegion.new(table, rowInner, colInner, fillType)
                       @childRegion<<pNewRegion
                       
                       rowInner += cell.GetCoveredScale().y - 1
                       rowInnerStart = rowInner + 1
                   end
                end
            end
        end
    end
    
    def GetRegionRect
        @rect
    end
    
    def GetFillType
        @fillType
    end
    
    def GetDesignTable
        @table
    end
    
    def AppendValue(table, pRegionValue)
        pRegionValue.AppendValue(table)
        for region in @childRegion
            rect = region.GetRegionRect()
            key = table.GetCellValue(rect.top, rect.left)
            next if key == ""
            
            pSubRegionValue = pRegionValue.GetChildRegion(region, key)
            region.AppendValue(table, pSubRegionValue)
        end
    end
end
