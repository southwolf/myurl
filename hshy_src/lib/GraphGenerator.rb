require 'RMagick' 
require 'rexml/document'
require 'EncodeUtil'
include REXML
include Magick 
include Math

ARROWLEN = 20
class GState
  attr_accessor :name, :x1, :x2, :y1, :y2
  def initialize(name, x1, y1, x2, y2)
    @name = name
    @x1 = x1
    @x2 = x2
    @y1 = y1
    @y2 = y2
  end
end

class GraphGenerator
  def initialize
    @states = []
  end
  
  def write_text(gc, text, x, y)
    gc.fill('red')  
    gc.text(x, y, text)  
    gc.fill('black')  
    gc.fill_opacity(0.1) 
  end
  
  def get_arrow(x1, y1, x2, y2)
    x = x1 - x2;
    y = y1 - y2;
    c = atan(y.to_f/x);
    if (c>0 && x<0 && y<0)
      c += PI;
    else(x<0 && y>=0)
      c += PI;
    end
    c1 = c + 20*PI/180;
    c2 = c - 20*PI/180;

    nx1 = cos(c1) * ARROWLEN + x2
    ny1 = sin(c1) * ARROWLEN + y2

    nx2 = cos(c2) * ARROWLEN + x2
    ny2 = sin(c2) * ARROWLEN + y2
    return nx1, ny1, nx2, ny2
  end
  
  def generate(xmlstr, name)
    doc = Document.new(xmlstr)
    root = doc.root

    img = Magick::Image.new(1200,600,Magick::HatchFill.new('white','white')) 
    gc = Magick::Draw.new  
    gc.stroke("black")
    gc.fill_opacity(0.1) 
    gc.pointsize(12)   
    gc.font("public/simsun.ttc") 
    gc.text_antialias(true)

    #解析开始状态节点
    root.elements.each("start") {|element|
            x1 = element.attributes["x1"].to_i
            y1 = element.attributes["y1"].to_i
            x2 = element.attributes["x2"].to_i
            y2 = element.attributes["y2"].to_i
            gc.arc(x1, y1, x2, y2, 0, 360)
            write_text(gc, EncodeUtil.change("UTF-8", "GB2312", "开始"), (x1+x2)/2 -20,(y1+y2)/2+4)
            @states << GState.new(EncodeUtil.change("UTF-8", "GB2312", "开始"), x1, y1, x2, y2)
            break
    }

    #解析所有状态节点
    root.elements.each("state") {|element|
            x1 = element.attributes["x1"].to_i
            y1 = element.attributes["y1"].to_i
            x2 = element.attributes["x2"].to_i
            y2 = element.attributes["y2"].to_i      
            gc.rectangle(x1, y1, x2, y2) 
            write_text(gc, element.attributes["name"], (x1+x2)/2 -20,(y1+y2)/2+4)
            @states << GState.new(element.attributes["name"], x1, y1, x2, y2)
    }

    #解析结束状态节点
    root.elements.each("end") {|element|
            x1 = element.attributes["x1"].to_i
            y1 = element.attributes["y1"].to_i
            x2 = element.attributes["x2"].to_i
            y2 = element.attributes["y2"].to_i
            gc.arc(x1, y1, x2, y2, 0, 360)
            write_text(gc, EncodeUtil.change("UTF-8", "GB2312", "结束"), (x1+x2)/2 -20,(y1+y2)/2+4)
            @states << GState.new(EncodeUtil.change("UTF-8", "GB2312", "结束"), x1, y1, x2, y2)
            break
    }
    #解析所有流转
    root.elements.each("trasit") {|element|
            from_name = element.attributes["from"]
            to_name = element.attributes["to"]
            from_state = nil
            to_state = nil
            @states.each{|e|
              from_state = e if e.name == from_name
              to_state = e if e.name == to_name
            }
            gc.line(from_state.x2,
              (from_state.y1+from_state.y2)/2,
              to_state.x1,
              (to_state.y1+to_state.y2)/2 )
            x1, y1, x2, y2 = get_arrow(from_state.x2,
                      (from_state.y1+from_state.y2)/2,
                      to_state.x1,
                      (to_state.y1+to_state.y2)/2 )
            gc.line(x1, y1, to_state.x1, (to_state.y1+to_state.y2)/2) 
            gc.line(x2, y2, to_state.x1, (to_state.y1+to_state.y2)/2)
    }
    gc.draw(img)
    file = "public/graph/#{name}.jpg"
    #file = "#{name}.jpg"
    img.write(file)
    file
  end
end

#g = GraphGenerator.new
#f = File.open("请假登记表.flo")
#xmlstr = f.read
#g.generate(xmlstr, "a")