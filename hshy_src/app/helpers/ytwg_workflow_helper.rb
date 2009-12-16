module YtwgWorkflowHelper
  # * ����һ��ֱ����һ�����εĽ���λ��
  # x1, y1 : �������ģ�ֱ���ϵ�һ����
  # x2, y2 : ֱ���ϵ���һ����
  # * height : ���θ߶�
  # * width  : ���ο��
  # ����[x, y]���ھ����ϵĽ���
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
