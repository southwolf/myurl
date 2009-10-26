


module ApplicationHelper
  
  def checkright(right)
    return false if !session[:user]
    user = YtwgUser.find(session[:user].id)
    return false if !user
    
    #对管理员返回真
    return true if session[:user].name == 'admin'
    
    moduleright = YtwgRight.find(:all, :conditions => "name = '#{right}'")
    #没有此权限则对所有用户返回真
    return true if moduleright.size == 0
    
    for group in user.groups
      for moduleright in group.rights
        return true if moduleright.name == right
      end
    end
    
    return false
  end
  
#  def ColorRow(index, id=nil)
#     result = ""
#     if index % 2 == 1
#	    #result = "<tr class='TrLight' #{"id='#{id}'" if id} onmouseover=\"this.style.backgroundColor ='#FFFFCC'\"  onmouseout=\"this.style.color='';this.style.backgroundColor =''\"> "
#	    result = "<tr class='TrLight' #{"id='#{id}'" if id} onmouseover=\"this.className ='Selected';\"  onmouseout=\"this.style.color='';this.className ='TrLight';\"> "
#	 else
#	    result = "<tr  #{"id='#{id}'" if id}  onmouseover=\"this.className ='Selected'\"  onmouseout=\"this.style.color='';this.className =''\"> "
#	 end
#	 result
#  end
  def ColorRow(index, id=nil, option={})
     result = ""
     id = 1 if !id
     
    options = ""
     option.each { |key,value|  
       next if key == :onclick
       options += " #{key.to_s} = #{value.to_s} "
     } if option
     
     if index % 2 == 1
        result = "<tr class='TrLight' id='#{id}' onmouseover='tr_mouseover(this)'  onmouseout='tr_mouseout(this)' onClick='tr_click(this);#{option[:onclick]}' #{options}> "
     else   
	result = "<tr  class = 'TrDark' id='#{id}' onmouseover='tr_mouseover(this)'  onmouseout='tr_mouseout(this)' onClick='tr_click(this);#{option[:onclick]}' #{options}> "
     end
     result
  end
  
  def sort_column(disp_name, field_name, action='list')
    order_str = params[:order] || "id asc"
    order_field = order_str.split(' ')[0]
    order_way = order_str.split(' ')[1]
    if order_field == field_name
      direction = 'asc'
      direction = 'desc' if order_way=='asc'
      "<a href='#{action}?order=#{field_name} #{direction}'>#{disp_name}</a>&nbsp;<img src='/img/#{direction}.gif'></img>"
    else
      "<a href='#{action}?order=#{field_name} asc'>#{disp_name}</a>"
    end
  end
  
  
  def round_table(width, title, &block)
    content = capture(&block)
   right_text = ""
   if title.is_a?(Array)
     right_text = title[1]
     title = title[0]
   end
   concat %!
 <table width="#{width}" border="0" cellspacing="0" cellpadding="0" class="bw_table">
  <thead>
    <tr>
      <th class="left" width=25%>#{title}</th>
      <th class="middle">&nbsp</th>
      <th class="right" width=20%>#{right_text}</th>
    </tr>
  </thead>
  <tbody>
    <tr>
    <td colspan="4" align=left >
        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="bw_inner">
            <tr>
              <td width=2>&nbsp;</td>
              <td align=left style="padding: 10px 10px;">
                #{content}
              </td>
              <td>&nbsp;</td>
            </tr>
        </table>
    </td>
    </tr>
   </tbody>
   <tfoot>
     <tr>
       <td colspan="2" class="tfoot_l"></td>
       <td colspan="2" class="tfoot_r"></td>
    </tr>
   </tfoot>
</table>
   !, block.binding        
  end

  def round_table1(width, title, &block)
   content = capture(&block)
   right_text = ""
   if title.is_a?(Array)
     right_text = title[1]
     title = title[0]
   end
   concat %!
      <table width="#{width}"  border="0"  cellspacing="0" cellpadding="0">
	<tr height=1 >
		<td colspan=2 width=2></td><td style="background:#666666" width=98%></td><td colspan=2 width=2></td>	
	</tr>
	<tr height=1 >
		<td width=1></td>
		<td width=1 style="background:#666666"></td>
		<td style="background:#999999" width=99%></td>
		<td width=1 style="background:#666666"></td>
		<td width=1></td>
	</tr>
	<tr height=1 style="background:black">
		<td width=1 style="background:#666666"></td>
		<td colspan=3 style="background:#999999" width=99%></td>
		<td width=1 style="background:#666666"></td>
	</tr>
	<tr height=15>
		<td width=1 style="background:#666666"></td>
		<td colspan=3 style="background:#999999;color:white" >
                <table width=100%>
                    <tr>
                       <td align='left'><b>&nbsp;#{title}</b></td>
                       <td align='right'><font color=black>#{right_text}&nbsp;</font></td>
                       <td align='right'></td>
                    </tr>
                </table>
                </td>
		<td width=1 style="background:#666666"></td>
	</tr>
	<tr height=10>
		<td width=1 style="background:#666666"></td>
		<td width=1 style="background:#999999"></td>
		<td style="background:#EEEEEE"><div style="display:block">#{content}</div></td>
		<td width=1 style="background:#999999"></td>
		<td width=1 style="background:#666666"></td>
	</tr>
	<tr height=1 style="background:black">
		<td width=1 style="background:#666666"></td>
		<td colspan=3 style="background:#999999" width=99%></td>
		<td width=1 style="background:#666666"></td>
	</tr>
	<tr height=1 >
		<td width=1></td>
		<td width=1 style="background:#666666"></td>
		<td style="background:#999999" width=99%></td>
		<td width=1 style="background:#666666"></td>
		<td width=1></td>
	</tr>
	<tr height=1 >
		<td colspan=2 width=2></td><td style="background:#666666" width=98%></td><td colspan=2 width=2></td>	
	</tr>
</table>
    !, block.binding
  end
  
    
    def round_table2(width, title, morelink, &block)
      content = capture(&block)
     right_text = ""
     if title.is_a?(Array)
       right_text = title[1]
       title = title[0]
     end
     concat %!
      <div>
      <table width="#{width}" border="0" cellspacing="0" cellpadding="00">
        <tr>
          <td width="19"><img src="/images/business_image_34.gif" alt="" width="19" height="26" align="absmiddle" /></td>
          <td width="136" background="/images/business_image_35.gif"><div class="mtop"><a href="#{morelink}" class="bhei">#{title}</a></div></td>
          <td width="51" align="right"><a href="#{morelink}" target="_blank"><img src="/images/business_image_37.gif" width="51" height="26" border="0" /></a></td>
        </tr>
      </table>
      
      <div style="margin-bottom:10px" width="#{width}">
        <table width="206" border="0" cellspacing="0" cellpadding="00">
          <tr>
          <td height="70" valign="top" background="/images/business_image_40.gif"><div style="margin-left:10px">       
            <div style="margin-left:10px;margin-top:10px"> #{content} </div>
          </td>
          </tr>
          <tr><td height="9" align="center"><img src="/images/business_image_58-1.gif" width="206" height="9" alt="" /></td></tr>
        </table>
      </div>
      </div>
      !, block.binding
    end
    
    
    def round_table3(width, title, morelink, &block)
     content = capture(&block)
     right_text = ""
     if title.is_a?(Array)
       right_text = title[1]
       title = title[0]
     end
     concat %!
      <table width="743" border="0" cellspacing="0" cellpadding="00">
        <tr>
          <td width="527"><table width="417" height="16" border="0" cellpadding="00" cellspacing="0">
              <tr>
                <td width="21"><img src="/images/business_image_81.gif" width="21" height="27" alt="" /></td>
                <td background="/images/business_image_82.gif"><div class="mtop">#{title}</div></td>
                <td width="10"><img src="/images/business_image_84.gif" width="10" height="27" alt="" /></td>
              </tr>
            </table>
            
            <table width="417" border="0" cellspacing="0" cellpadding="00">
              <tr><td height="114" valign="top" background="/images/business_image_108.gif">
                  #{content}
              </td></tr>
              <tr><td height="6"><img src="/images/business_image_130.gif" width="417" height="6" alt="" /></td></tr>
            </table>
            
          </td>
          <td width="316">
            </td>
        </tr>
      </table>
      !, block.binding
    end
    
    #弹出div
    def popup_div(width, height, title, tagid, &block)
      content = capture(&block)
     right_text = ""
     if title.is_a?(Array)
       right_text = title[1]
       title = title[0]
     end
     concat %!
      <div id="#{tagid}" class="popup_layer" style="width:#{width}px;height:#{height}px">
        <div class="popup_title_bar">
        	<div class="popup_title_text">#{title}</div>
        	<div class="popup_title_close"><a href="#" onclick="Lock_CheckForm('#{tagid}');">[#{'关闭'}]</a></div>
        </div>	
        <div class="popup_split_left" style="height:#{height-24}px"></div>
      	<div class="popup_content" style="height:#{height-24}px">
      		#{content}
      	</div>
        <div class="popup_split_right" style="height:#{height-24}px"></div>
    </div>
      !, block.binding
    end
    
    #弹出提示
    def popup_tip(width, height, tagid, &block)
      content = capture(&block)
     concat %!
      <div id="#{tagid}" class="popup_tip" style="width:#{width}px;height:#{height}px">
      	<div class="popup_content" style="height:#{height-24}px">
      		#{content}
      	</div>
    </div>
      !, block.binding
    end
  
    def params_for_javascript(params) #options_for_javascript doesn't works fine
        
        '{' + params.map {|k, v| "#{k}: #{ 
            case v
              when Hash then params_for_javascript( v )
              when String then "'#{v}'"          
            else v   #Isn't neither Hash or String
            end }"}.sort.join(', ') + '}'
    end
    
    
    
    def link_to_prototype_dialog( name, content, dialog_kind = 'alert', options = { :windowParameters => {} } , html_options = {} )
    
        #dialog_kind: 'alert' (default), 'confirm' or 'info' (info dialogs should be destroyed with a javascript function call 'win.destroy')
        #options for this helper depending the dialog_kind: http://prototype-window.xilinus.com/documentation.html#alert (#confirm or #info)
    
        js_code ="Dialog.#{dialog_kind}( '#{content}',  #{params_for_javascript(options) } ); "
        content_tag(
               "a", name, 
               html_options.merge({ 
                 :href => html_options[:href] || "#", 
                 :onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + js_code }))
    end
    
    
    
    def link_to_prototype_window( name, window_id, options = { :windowParameters => {} } , html_options = {} )
        
        #window_id must be unique and it's destroyed on window close.
        #options for this helper: http://prototype-window.xilinus.com/documentation.html#initialize
      
        js_code ="var win = new Window( '#{window_id}', #{params_for_javascript(options) } );  win.show();  win.setDestroyOnClose();"
        content_tag(
               "a", name, 
               html_options.merge({ 
                 :href => html_options[:href] || "#", 
                 :onclick => (html_options[:onclick] ? "#{html_options[:onclick]}; " : "") + js_code }))
    end
    
#    def image_button(text, url, *arg)
#      leftimage = ""
#      if arg.size > 0 && arg[0][:image]
#        leftimage = %!<IMG class="Button_Icon Button_Icon_ok" alt="Logn" title="Login" src="/img/#{arg[0][:image]}" border="0"></IMG>!
#      end 
#      %!
#  <A class="ButtonLink" href="#" onfocus="this.className='ButtonLink_hover'; window.status='#{text}'; return true;" onblur="this.className='ButtonLink'; window.status=''; return true;" onkeypress="this.className='ButtonLink_active'; return true;" onkeyup="this.className='ButtonLink_hover'; return true;" onclick="document.location='#{url}'">
#    <TABLE style="display:inline" class="Button" onmousedown="this.className='Button_active'; return true;" onmouseup="this.className='Button'; return true;" onmouseover="this.className='Button_hover'; window.status='Login'; return true;" onmouseout="this.className='Button'; window.status=''; return true;">
#      <TR>
#        <TD class="Button_left">#{leftimage}</TD>
#        <TD class="Button_text Button_width">#{text}</TD>
#        <TD class="Button_right"></TD>
#      </TR>
#    </TABLE>
#  </A>
#      !
#    end
    
    def image_wide_button(text, url, *arg)
      leftimage = ""
      if arg.size > 0 && arg[0][:image]
        leftimage = %!<IMG class="Button_Icon Button_Icon_ok" alt="Logn" title="Login" src="/img/#{arg[0][:image]}" border="0"></IMG>!
      end 
            %!
  <A class="ButtonLink" href="#" onfocus="this.className='ButtonLink_hover'; window.status='#{text}'; return true;" onblur="this.className='ButtonLink'; window.status=''; return true;" onkeypress="this.className='ButtonLink_active'; return true;" onkeyup="this.className='ButtonLink_hover'; return true;" onclick="document.location='#{url}'">
    <TABLE style="display:inline" class="Button" onmousedown="this.className='Button_active'; return true;" onmouseup="this.className='Button'; return true;" onmouseover="this.className='Button_hover'; window.status='Login'; return true;" onmouseout="this.className='Button'; window.status=''; return true;">
      <TR>
        <TD class="Button_left">#{leftimage}</TD>
        <TD class="Button_text">#{text}</TD>
        <TD class="Button_right"></TD>
      </TR>
    </TABLE>
  </A>
      !
    end
    
    alias image_button image_wide_button

   
    def show_departmenttree(linkurl, target=nil)
    result = ''
    departments = Department.find(:all, :conditions=>"parent_id is null or parent_id = -1")
    for d in departments
      result << "var tree#{d.id} = new WebFXTree('#{d.name}');\n"
      result << "tree#{d.id}.icon = '/img/department.gif';\n"
      result << "tree#{d.id}.openIcon = '/img/department.gif';\n"
      result << "tree#{d.id}.target = '#{target}';\n" if target
      result << "tree#{d.id}.action = '#{linkurl}/#{d.id}';\n"
      result << show_subnode(d, linkurl, target)
      result << "document.write(tree#{d.id});tree#{d.id}.expandAll();\n"
    end
    return result
  end
  
  def show_subnode(map, linkurl, target=nil)
    result = ''
    for child in map.children
      result << "tree#{child.id} = tree#{map.id}.add(new WebFXTreeItem('#{child.name}'));\n"
      result << "tree#{child.id}.openIcon = '/img/department.gif';"
      result << "tree#{child.id}.icon = '/img/department.gif';"
      result << "tree#{child.id}.target = '#{target}';\n" if target
      result << "tree#{child.id}.action = '#{linkurl}/#{child.id}';\n"
      result << show_subnode(child, linkurl, target)
    end
    
    result 
  end
end


module ActionView::Helpers::FormTagHelper
  def submit_tag_bak(text, *arg)
    leftimage = ""
      if arg.size > 0 && arg[0][:image]
        leftimage = %!<IMG  alt="Logn" title="Login" src="/img/#{arg[0][:image]}" border="0"></IMG>!
      end 
      
      prestr = ""
      if arg.size > 0 && arg[0][:pre]
        prestr = arg[0][:pre]
      end
      %!
  <A class="ButtonLink" href="#" onfocus="this.className='ButtonLink_hover'; window.status='#{text}'; return true;" onblur="this.className='ButtonLink'; window.status=''; return true;" onkeypress="this.className='ButtonLink_active'; return true;" onkeyup="this.className='ButtonLink_hover'; return true;" onclick="#{prestr};submit();">
    <TABLE style="display:inline;" class="Button" onmousedown="this.className='Button_active'; return true;" onmouseup="this.className='Button'; return true;" onmouseover="this.className='Button_hover'; window.status='Login'; return true;" onmouseout="this.className='Button'; window.status=''; return true;">
      <TR>
        <TD class="Button_left">#{leftimage}</TD>
        <TD class="Button_text">#{text}</TD>
        <TD class="Button_right"></TD>
      </TR>
    </TABLE>
  </A>
      !
    end
    
  def remote_submit_tag_bak(value = "Save changes", options = {})
       tag("input", { "type" => "submit", "name" => "commit", "value" => value })
  end
  
  def distance_of_time_in_words1(from_time, include_seconds = false)
        to_time = Time.new
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round

        case distance_in_minutes
          when 0..1
            return (distance_in_minutes == 0) ? '不到1分钟' : '1分钟' unless include_seconds
            case distance_in_seconds
              when 0..4   then '不到5秒'
              when 5..9   then '不到10秒'
              when 10..19 then '不到20秒'
              when 20..39 then '半分钟'
              when 40..59 then '不到1分钟'
              else             '1分钟'
            end

          when 2..44           then "#{distance_in_minutes}分钟"
          when 45..89          then '1小时'
          when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round}小时"
          when 1440..2879      then '1天'
          when 2880..43199     then "#{(distance_in_minutes / 1440).round}天"
          when 43200..86399    then '1个月'
          when 86400..525959   then "#{(distance_in_minutes / 43200).round}个月"
          when 525960..1051919 then '1年'
          else                      "over #{(distance_in_minutes / 525960).round}年"
        end
  end

end