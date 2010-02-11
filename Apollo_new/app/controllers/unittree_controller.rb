class UnittreeController < ApplicationController
  
  def getchildunit  
    parent = params[:id]
    sublink = params[:sublink]
    updatediv = params[:updatediv]     
    target = params[:target]
    doc = Document.new("<?xml version='1.0' encoding='gb2312'?><treeRoot></treeRoot>")
    taskmeta = $TaskDesc[session[:task].strid]
    Unit.set_table_name("ytapl_#{taskmeta.taskid}_#{taskmeta.fmtable}".downcase)
    units = Unit.find(:all, :conditions =>"p_parent = '#{parent}'")
    units.sort!
    for unit in units
      next if params[:showhidden]!="true" && unit["display"].to_s == '0'
      
      #判断读权限
      #next if CheckUnitRight(session[:task].taskid, session[:user].id, unit.unitid) == 0
      #是单户企业且用户没有权限      
      if ['0','1'].include?(unit.unitid[unit.unitid.size-1,1]) && !CheckRight(session[:user].id, "查看底层单位数据")
        next
      end
      
      newnode = doc.root.add_element(Element.new('tree'))
      attr = Hash.new
      attr['text'] = unit[taskmeta.unitname]
      if Unit.find(:all, :conditions => "p_parent = '#{unit.unitid}'").length > 0
        attr['src'] = "/unittree/getchildunit/#{unit['unitid']}?sublink=#{sublink}&updatediv=#{updatediv}&target=#{target}&showhidden=#{params[:showhidden]}"
      end
      attr['icon'] = "/img/icon_#{unit[taskmeta.reporttype]}.gif"
      attr['openIcon'] = "/img/icon_#{unit[taskmeta.reporttype]}.gif"
      attr['checkValue'] = unit["unitid"]
      #print "\n-----------------sublink is --------------------\n"

      if sublink && sublink.length > 0
        attr['action'] = "#{sublink}/#{unit['unitid']}"
      else
        attr['action'] = "javascript:void(0)"
      end
      
      if !params[:target] || params[:target]==''
        attr['clickFunc'] = "new Ajax.Updater('#{updatediv}', '#{sublink}/#{unit['unitid']}', {asynchronous:true}); return false;"
      end
      attr['target'] = target if params[:target]!="" && target
      newnode.add_attributes(attr)
    end  
    
    xmlstr = ''
    
    doc.write(Output.new(xmlstr, "UTF-8"), -1)
    #print EncodeUtil.change("GB2312", "UTF-8",xmlstr)
    send_data xmlstr, :type =>"text/xml"
  end
  
  ###########代码字典树回调##################
  def getdiction
    doc = Document.new("<?xml version='1.0' encoding='gb2312'?><treeRoot></treeRoot>")
    meta = $TaskDesc[session[:task].strid]
    dict = meta.helper.dictionFactory.GetDictionByID(params[:diction])
    parent = params[:pre].to_s || ""
    (parent.length-1).downto(0) do |i|
	   if parent[i] == 48
		parent[i] = ''
       else
        break
	   end
	end

    levels = dict.Levels.split(',')
    levels << dict.Length if levels.size == 0
    
    if parent.size > 0
	 for level in levels
	   if level.to_i >= parent.size
	     parent = parent.ljust(level.to_i, '0')
	     break
	   end
	 end
	end
	
    for level in levels
      if level.to_i > parent.size
        items = dict.GetAllItems()
        keys = items.keys
        keys.sort!
        for item in keys
          value = items[item]
          if item[level.to_i, dict.Length-level.to_i] == "0"*(dict.Length-level.to_i) && parent == item[0, parent.size] && (item[parent.size, dict.Length-parent.size] != "0"*(dict.Length-parent.size) || item=='0'*item.size())
            newnode = doc.root.add_element(Element.new('tree'))
            attr = Hash.new
            attr['text'] = value
            if level.to_i < dict.Length
              attr['src'] = "/unittree/getdiction?pre=#{item}&diction=#{params[:diction]}&cellname=#{params[:cellname]}"
            end
            attr['icon'] = "/img/icon_0.gif"
            attr['openIcon'] = "/img/icon_0.gif"
            
            copyindex = item.size
            (item.size-1).downto(0) do |i|
	          if item[i] != 48
                copyindex = i+1
                break
	          end
	        end
	        likeitem = item[0, copyindex]	        
            attr['checkValue'] = "#{params[:cellname]} like '#{likeitem}%'"
            attr['kind'] = 'dict'
            newnode.add_attributes(attr)
          end
        end    
        break
      end
    end    
    
    xmlstr = ''    
    doc.write(Output.new(xmlstr, "UTF-8"), -1)
    send_data xmlstr, :type =>"text/xml"
  end

end