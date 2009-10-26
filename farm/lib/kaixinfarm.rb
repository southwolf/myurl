require 'httpclient'
require 'hpricot'  
require 'common'

class KaixinFarm
	attr_accessor :user_id
	def initialize
		@clnt = HTTPClient.new
		@clnt.set_cookie_store('cookie.dat')
		@headers = [['User-Agent', 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)']]
	end
	
	def close
	   @clnt.reset_all
	end
	
	def login(username ,password)
		params={}
		params['url'] = "/home/"
		params["email"] = username
		params['password'] = password
		res = @clnt.post('http://www.kaixin001.com/login/login.php', params, @headers)
		dumpfile(res.body.content, 'd:\kk.html')
		if res.header['Location'] && res.header['Location'].size > 0
			res.header['Location'][0].scan(/uid=(\d+)/)
			@user_id = $1
			@clnt.get_content("http://www.kaixin001.com/home/?uid=#{@user_id}")
			return true
		else
			return false
		end
	end
	
	def get_friends
		content = @clnt.get_content("http://www.kaixin001.com/friend/?uid=#{@user_id}")
		doc = Hpricot(content)
		@myfriends = parse_friends(doc)
		
		for page in doc.at("//div[@class='tac']").search('/a').collect{|a| a.attributes['href']}.compact.uniq do
			content = @clnt.get_content("http://www.kaixin001.com/friend/#{page}")
			newdoc = Hpricot(content)
			@myfriends += parse_friends(newdoc)
		end
		@myfriends
	end
	
	def get_farm_conf(user_id)
	 @clnt.get_content("http://www.kaixin001.com/!house/!garden/getconf.php?fuid=#{user_id}")
	end
	
	def exam_farm
	    @myfriends.unshift([@user_id , '自己'])
		for friend in @myfriends
			#puts EncodeUtil.change('gb2312', 'utf-8', friend[1])
			content = @clnt.get_content("http://www.kaixin001.com/!house/!garden/getconf.php?fuid=#{friend[0]}")
    		doc = Hpricot(content)
    		doc.search("/conf/garden/item").each do |item|
    		  cropsid = item.at('cropsid').inner_text
    		  next if cropsid.to_i == 0
    		  next if !item.at('crops')
    		  crops = item.at('crops').inner_text
    		  if item.at('totalgrow').inner_text.to_i > item.at('grow').inner_text.to_i
    		  	#puts "#{item.at('farmnum').inner_text} #{item.at('shared').inner_text} #{cropsid} #{EncodeUtil.change('gb2312', 'UTF-8', item.at('name').inner_text)} #{EncodeUtil.change('gb2312', 'utf-8', item.at('crops').inner_text)}" 
    		  	if crops.scan(/(距离收获.+)/).size > 0
    		  	  havest_time =  timestr_to_time($1)
    		  	  add_task(havest_time, friend[0], friend[1], item.at('farmnum').inner_text, item.at('name').inner_text)
    		  	end
    		  elsif item.at('totalgrow').inner_text.to_i == item.at('grow').inner_text.to_i #已经成熟了
                next if crops.scan(/(已枯死)/).size > 0
    		    #有些菜成熟后需要等一段时间才能偷
    		    havest_time = Time.new
    		    havest_time =  timestr_to_time($1) if crops.scan(/再过(.+)可偷/).size > 0
    		    add_task(havest_time, friend[0], friend[1], item.at('farmnum').inner_text, item.at('name').inner_text)
    		  end
    		end 
		end
	end
	
	def add_task(havest_time, friend_id, friend_name, farmnum, fruitname)
	  havest_time += 60-havest_time.sec
	  
	  if !Kaixintask.find(:first, :conditions=>"kaixinuserid=#{@user_id} and kaixinfriendid=#{friend_id} and occurtime = '#{havest_time.to_formatted_s(:db)}' and farmnum=#{farmnum}")
    	  task =  Kaixintask.new
    	  task.tasktype = 1
    	  task.occurtime = havest_time
    	  task.kaixinuserid = @user_id
    	  task.kaixinfriendid = friend_id
    	  task.kaixinfriendname = friend_name
    	  task.farmnum = farmnum
    	  task.fruitname = fruitname
    	  task.save
	  end
	end
	
	#收菜, friendid: 用户id, farmnum: 菜地编号
	#返回：[收菜数量, 收菜种类]
	def harvest(friendid, farmnum)
	  p "http://www.kaixin001.com/!house/!garden/havest.php?fuid=#{friendid}&farmnum=#{farmnum}"
	  content = @clnt.get_content("http://www.kaixin001.com/!house/!garden/havest.php?fuid=#{friendid}&farmnum=#{farmnum}")
	  p content
	  doc = Hpricot(content)
	  if doc.at('/data/num') && doc.at('/data/seedname')
	   [doc.at('/data/num').inner_text, doc.at('/data/seedname').inner_text]
	  elsif doc.at('/data/reason')
	   [0, doc.at('/data/reason').inner_text]
	  else
	   [0, '收菜失败']
	  end
	end
private
  def parse_friends(doc)
		res = []
		
		doc.at("//div[@class='gw']").containers[7].search('/div').each do |div|
			begin
				friend = div.containers[0].at('/div/a') 
		  rescue
		  	next
		  end
			next if !friend
			friend.attributes['href'].scan(/uid=(\d+)/)
			res << [$1, friend.attributes['title']]
		end
		return res
	end	
end

#farm = KaixinFarm.new
#if farm.login('lmxbitihero@gmail.com', '330012')
#	 farm.get_friends
#	 farm.exam_farm
#end