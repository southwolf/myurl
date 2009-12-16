module RealtimeviewHelper
  def show_cameratree
    result = ''
    maps = Emap.find(:all, :conditions=>"parentid = -1")
    for map in maps
      result << "var tree#{map.id} = new WebFXTree('#{map.mapname}');\n"
      
      cameras = Camera.find(:all, :conditions=>"mapid=#{map.id}")
      for camera in cameras
        result << %Q! camera#{camera.id} = tree#{map.id}.add(new WebFXTreeItem('#{camera.sourcename}', "javascript:OnClickCamera(#{camera.id}, '#{camera.sourcename}',curActiveID)", '', '/img/3_14.gif'));
        !
      end
      result << show_subnode(map)
      result << "document.write(tree#{map.id});\n"
    end
    return result
  end
  
  def show_subnode(map)
    result = ''
    for child in map.children
      result << "tree#{child.id} = tree#{map.id}.add(new WebFXTreeItem('#{child.mapname}'));\n"
      
      cameras = Camera.find(:all, :conditions=>"mapid=#{child.id}")
      for camera in cameras
        result << %Q! camera#{camera.id} = tree#{map.id}.add(new WebFXTreeItem('#{camera.sourcename}', "javascript:OnClickCamera(#{camera.id}, '#{camera.sourcename}',curActiveID)", '', '/img/3_14.gif'));
                var cam = new Object();
	        cam.id = #{camera.id};
	        cam.name = '#{camera.sourcename}';
	        cam.mapid = #{camera.mapid};
	        cam.issplitter = false;
	        cam.arr_ps = new Array();//ÉãÏñÍ·Ô¤ÖÃÎ»;
	        cam.arr_aux = new Array();//¸¨ÖúÎ»
	        cam.arr_dodi = new Array();//¼ÌµçÆ÷
	        cam.arr_macro  = new Array(); //ºê
	        cameraList[#{camera.id}]=cam;
        !
      end
      result << show_subnode(child)
    end
    
    result 
  end
end
