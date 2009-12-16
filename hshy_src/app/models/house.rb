class House < ActiveRecord::Base
  has_many :photo
  has_many :viewlog
  belongs_to :quyu, :class_name=>"Quyu", :foreign_key=>"quyu_id"
  validates_presence_of :d, :message=>"楼号必填"
  validates_presence_of :danyuan, :message=>"单元号必填"
  validates_presence_of :h, :message=>"门牌号必填"
  validates_presence_of :price, :message=>"报价必填"
  validates_presence_of :zc, :message=>"总层必填"
  validates_presence_of :szc, :message=>"所在层必填"
  validates_presence_of :lxr, :message=>"联系人必填"
  validates_presence_of :telephone, :message=>"联系人电话必填"
  validates_presence_of :dj, :message=>"底价必填"
  validates_presence_of :mj, :message=>"面积必填"
  validates_presence_of :kfsj, :message=>"看房时间必填"
  validates_presence_of :zsp, :message=>"备注必填"
  
  def name
    "#{self.quyu} #{self.xq}小区#{self.d}栋#{self.danyuan}单元#{self.l}楼#{self.h}号"
  end

  def page
    count = House.count("tag = #{self.tag} and ku= #{self.ku} and id >= #{self.id}")
    p1  = count / 20 
    p1 += 1 if count % 20 > 0
    return p1
  end
end
