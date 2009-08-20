module MainHelper
  def show_catalog_combo(value)
    result = ''
    result << "<option value=0 #{'selected="selected"' if value.to_s == '0'}>收藏</option>"
    catalogs = Catalog.find(:all, :conditions=>"user_id = #{session[:user].id} and parent_id is null")
    for catalog in catalogs
      result << "<option #{'selected="selected"' if value.to_s == catalog.id.to_s} value=#{catalog.id}>#{'&nbsp;'*4}#{catalog.name}</option>\n"
      result << show_sub_combo(catalog, 8, value)
    end
    return result
  end  
  
  def show_sub_combo(catalog, indent, value)
    result = ''
    for child in catalog.children
      result << "<option #{'selected="selected"' if value.to_s == child.id.to_s} value=#{child.id}>#{'&nbsp;'*indent}#{child.name}</option>\n"
      result << show_sub_combo(child, indent+4, value)
    end
    
    result
  end
  
  def show_catalog_tree2
    result = ''
    result << "var tree = new WebFXTree('收藏');"
    result << "tree.action = '/main/myurl?cata=0';"
    result << "tree.icon = '/images/star.png';"
    result << "tree.openIcon = '/images/star.png';"
    
    catalogs = Catalog.find(:all, :conditions=>"user_id = #{session[:user].id} and parent_id is null")
    for catalog in catalogs
      result << "var tree#{catalog.id} = new WebFXTreeItem('#{catalog.name}');\n"
      result << "tree.add(tree#{catalog.id});"
      result << "tree#{catalog.id}.action = '/main/myurl?cata=#{catalog.id}';\n"
      result << "tree#{catalog.id}.icon = '/images/folder.png';"
      result << "tree#{catalog.id}.openIcon = '/images/folder.png';"
      result << show_subnode(catalog)
    end
    result << "document.write(tree); tree.expandAll();"
    return result
  end
  
  def show_subnode(catalog)
    result = ''
    for child in catalog.children
      result << "var tree#{child.id} = new WebFXTreeItem('#{child.name}');\n"
      result << "tree#{child.id}.icon = '/images/folder.png';"
      result << "tree#{child.id}.openIcon = '/images/folder.png';"
      result << "tree#{child.id} = tree#{catalog.id}.add(tree#{child.id});\n"
      result << "tree#{child.id}.action = '/main/myurl?cata=#{child.id}';\n"
      result << show_subnode(child)
    end
    
    result 
  end
  
  def distance_of_time_in_words1(from_time, include_seconds = false)
        to_time = Time.new
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round

        case distance_in_minutes
          when 0..1
            return (distance_in_minutes == 0) ? '不到1分钟' : '1分钟' unless include_seconds
            case distance_in_seconds
              when 0..4   then '不到5秒'
              when 5..9   then '不到10秒'
              when 10..19 then '不到20秒'
              when 20..39 then '半分钟'
              when 40..59 then '不到1分钟'
              else             '1分钟'
            end

          when 2..44           then "#{distance_in_minutes}分钟"
          when 45..89          then '1小时'
          when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round}小时"
          when 1440..2879      then '1天'
          when 2880..43199     then "#{(distance_in_minutes / 1440).round}天"
          when 43200..86399    then '1个月'
          when 86400..525959   then "#{(distance_in_minutes / 43200).round}个月"
          when 525960..1051919 then '1年'
          else                      "over #{(distance_in_minutes / 525960).round}年"
        end
      end
  
  def order(serial, value)
    serial.index(value)*100/serial.size
  end
end
