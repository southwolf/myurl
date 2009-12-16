class House < ActiveRecord::Base
  has_many :photo
  has_many :viewlog
  belongs_to :quyu, :class_name=>"Quyu", :foreign_key=>"quyu_id"
  validates_presence_of :d, :message=>"¥�ű���"
  validates_presence_of :danyuan, :message=>"��Ԫ�ű���"
  validates_presence_of :h, :message=>"���ƺű���"
  validates_presence_of :price, :message=>"���۱���"
  validates_presence_of :zc, :message=>"�ܲ����"
  validates_presence_of :szc, :message=>"���ڲ����"
  validates_presence_of :lxr, :message=>"��ϵ�˱���"
  validates_presence_of :telephone, :message=>"��ϵ�˵绰����"
  validates_presence_of :dj, :message=>"�׼۱���"
  validates_presence_of :mj, :message=>"�������"
  validates_presence_of :kfsj, :message=>"����ʱ�����"
  validates_presence_of :zsp, :message=>"��ע����"
  
  def name
    "#{self.quyu} #{self.xq}С��#{self.d}��#{self.danyuan}��Ԫ#{self.l}¥#{self.h}��"
  end

  def page
    count = House.count("tag = #{self.tag} and ku= #{self.ku} and id >= #{self.id}")
    p1  = count / 20 
    p1 += 1 if count % 20 > 0
    return p1
  end
end
