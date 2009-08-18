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
  
end
