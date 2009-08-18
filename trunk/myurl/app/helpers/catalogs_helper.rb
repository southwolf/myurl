module CatalogsHelper
  def show_catalog_tree
    result = ''
    result << "var tree = new WebFXTree('收藏');"
    result << "tree.action = '/catalogs/list';"
    result << "tree.icon = '/images/star.png';"
    result << "tree.openIcon = '/images/star.png';"
    
    catalogs = Catalog.find(:all, :conditions=>"user_id = #{session[:user].id} and parent_id is null")
    for catalog in catalogs
      result << "var tree#{catalog.id} = new WebFXTreeItem('#{catalog.name}');\n"
      result << "tree.add(tree#{catalog.id});"
      result << "tree#{catalog.id}.action = '/catalogs/list/#{catalog.id}';\n"
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
      result << "tree#{child.id}.action = '/catalogs/list/#{child.id}';\n"
      result << show_subnode(child)
    end
    
    result 
  end

  
end
