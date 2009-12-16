require "RegionValue"
require "ReportUtil"
require "Size"
require "Const"
class RegionValueTree
    
    def initialize(pRegion)
        @pRegion = pRegion
        @pRegionValues = Hash.new()
    end
    
    def GetRegion(key)
        if !@pRegionValues.has_key?(key)
            pRegionValue = RegionValue.new(@pRegion)
            @pRegionValues[key] = pRegionValue
        end
        
        @pRegionValues[key]
    end
    
    def GetAppendedRowsOrCols
        count = GetRegionRowsOrCols();
        if @pRegion.GetFillType() == FILL_HORIZONTAL
            count -= @pRegion.GetRegionRect().Width() + 1
        else
            count -= @pRegion.GetRegionRect().Height() + 1
        end
        
        count
    end
    
    def GetRegionRowsOrCols
        count = 0
        @pRegionValues.each {|key, pRegionValue|
            count += pRegionValue.GetRegionRowsOrCols()
        }
        
        if @pRegionValues.length == 0
            if @pRegion.GetFillType() == FILL_HORIZONTAL
                count = @pRegion.GetRegionRect().Width() + 1
            else
                count = @pRegion.GetRegionRect().Height() + 1
            end
        end
        
        count
    end
    
    def FillTable(pTable, pRowOrColBegin)
        pTableDesign = @pRegion.GetDesignTable()
        if @pRegionValues.empty?
            rectCopy = CRect.new(@pRegion.GetRegionRect())
            
            appendedRowsOrCols = 0
            ReportUtil::CopyCellRegion(pTableDesign, rectCopy, nil, pTable, pRowOrColBegin, appendedRowsOrCols, @pRegion.GetFillType())
            
            if @pRegion.GetFillType() == FILL_VERTICAL
                pRowOrColBegin += rectCopy.Height() + 1
            else
                pRowOrColBegin += rectCopy.Width() + 1
            end
        else
            position_hash = Hash.new
            isDouble = false
            @pRegionValues.each{|key, pRegionValue|
                if pRegionValue.values[0].GetType() == DOUBLE
                    isDouble = true
                    position_hash[key.to_f] = key
                else
                    position_hash[key] = key
                end
            }
            keys = position_hash.keys.sort    
            #keys.reverse! if isDouble
            
            for key in keys
                pRowOrColBegin = @pRegionValues[position_hash[key]].FillTable(pTable, pRowOrColBegin)
            end
        end
        
        pRowOrColBegin
    end
    
end