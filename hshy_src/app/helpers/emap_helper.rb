module EmapHelper
  def show_maptree
    result = ''
    maps = Emap.find(:all, :conditions=>"parentid = -1")
    for map in maps
      result << "var tree#{map.id} = new WebFXTree('#{map.mapname}');\n"
      result << "tree#{map.id}.action = '/emap/edit/#{map.id}';\n"
      result << show_subnode(map)
      result << "document.write(tree#{map.id});tree#{map.id}.expandAll();\n"
    end
    return result
  end
  
  def show_subnode(map)
    result = ''
    for child in map.children
      result << "tree#{child.id} = tree#{map.id}.add(new WebFXTreeItem('#{child.mapname}'));\n"
      result << "tree#{child.id}.action = '/emap/edit/#{child.id}';\n"
      result << show_subnode(child)
    end
    
    result 
  end
end
