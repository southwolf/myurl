# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def round_div(width, &block)
     content = capture(&block)
     
     concat %!
     <div id="nifty" style="width=#{width}"> 
        <div class="rtop"> 
            <div class="r1"></div> 
            <div class="r2"></div> 
            <div class="r3"></div> 
            <div class="r4"></div> 
        </div> 
        <div class="nifty_inner"><p>#{content}</p></div>
      <div class="rtop"> 
            <div class="r4"></div> 
            <div class="r3"></div> 
            <div class="r2"></div> 
            <div class="r1"></div> 
        </div> 
    </div>
      !, block.binding
  end
    
  def round_table(width, title, &block)
    content = capture(&block)
   right_text = ""
   if title.is_a?(Array)
     right_text = title[1]
     title = title[0]
   end
   concat %!
 <table style="border-color:red" width="#{width}" border="0" cellspacing="0" cellpadding="0" class="bw_table">
  <thead>
    <tr width="100%">
      <th align="left" class="left" width=30%>#{title}</th>
      <th class="middle">&nbsp</th>
      <th class="right" width=20%>#{right_text}</th>
    </tr>
  </thead>
  <tbody>
    <tr>
    <td colspan="3" align=left >
        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="bw_inner">
            <tr>
              <td style="padding:0px; align:left">
                #{content}
              </td>
            </tr>
        </table>
    </td>
    </tr>
   </tbody>
   <tfoot>
     <tr>
       <td colspan="2" class="tfoot_l"></td>
       <td class="tfoot_r"></td>
    </tr>
   </tfoot>
</table>
   !, block.binding        
  end  
end
