module YtwgWorkflowHelper
  # * 计算一条直线与一个矩形的交点位置
  # x1, y1 : 矩形中心，直线上的一个点
  # x2, y2 : 直线上的另一个点
  # * height : 矩形高度
  # * width  : 矩形宽度
  # 返回[x, y]，在矩形上的交点
  # */
  def AcrossPoint(x1, y1, x2, y2, height, width)
    p "#{x1} #{y1} #{x2} #{y2} #{height} #{width}"
    x = x2 - x1;
    y = y2 - y1;

    _x1 = 0;
    _y1 = 0;

    h = height.abs / 2;
    w = width.abs / 2;

    s1 = (x*h*h/y).abs if y!=0
    s1 = 100000 if y == 0
    s2 = (y*w*w/x).abs if x!=0
    s2 = 100000 if x == 0
    if (s1<s2)
      _x1 = x*h/y
      _y1 = h
    else
      _x1 = w;
      _y1 = y*w/x;
    end
    if ((x>0 && _x1<0)||(x<0 && _x1>0))
            _x1 = 0-_x1
    end
    if ((y>0 && _y1<0)||(y<0 && _y1>0))
            _y1 = 0-_y1;
    end
    [_x1 + x1, _y1 + y1]
  end
end
