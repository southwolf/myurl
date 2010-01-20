class YtwgTemplateController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @ytwg_template_pages, @ytwg_templates = paginate :ytwg_templates, :per_page => 10
  end

  def show
    @ytwg_template = YtwgTemplate.find(params[:id])
  end

  def new
    @ytwg_template = YtwgTemplate.new
  end

  def create
    stream = params[:ytwg_template][:content]
    content = stream.read
    name = stream.original_filename[0, stream.original_filename.index(".")]
    
    tts = YtwgTemplate.find(:all, :conditions=>"name='#{name}'")
    if tts.size > 0
      @ytwg_template = tts[0]
    else
      @ytwg_template = YtwgTemplate.new()
    end
    
    @ytwg_template.name = name
    #@ytwg_template.content = EncodeUtil.change('UTF-8', 'GB2312', content)
    @ytwg_template.content = content
    
    
    if @ytwg_template.save
      YtLog.info name, '更新模板'
      helper = XMLHelper.new
      helper.ReadFromString(content)
      $Templates[name] = helper
      if tts.size > 0
        flash[:notice] = '修改模板成功'
      else
        flash[:notice] = '上传模板成功'
        
        if params[:create_table] == "1"
          #建表
          helper = XMLHelper.new
          helper.ReadFromString(content)
          formtable = helper.tables[0]
          conn = ActiveRecord::Base.connection
          conn.create_table "ytwg_#{formtable.GetTableID.downcase()}", :primary_key=>:id do |t|
            t.column "userid", :integer         #流程发起人的id
            t.column "flowid", :integer         #工作流的id
            t.column "_remark", :integer         #注释
      
            t.column "_state", :string, :limit=>30
            t.column "_madetime", :datetime
            t.column "_lastprocesstime", :datetime
            t.column "create_at", :datetime
                
            Integer(0).upto(formtable.GetRowCount()-1) do |row|
              next if formtable.IsEmptyRow(row)
              Integer(0).upto(formtable.GetColumnCount()-1) do |col|
                next if formtable.IsEmptyCol(col)
                cell = formtable.GetCell(row, col)
                next if !cell.IsStore || !cell.IsEffective
                next if formtable.GetCellDBFieldName(row, col).downcase == "id"
          	     
                
                if cell.GetDataType == 1    #CCell.CtNumeric
                  t.column formtable.GetCellDBFieldName(row, col).downcase, :float
                elsif cell.GetDataType == 0    #CCell.CtText               
                  if cell.IsCheckWidth()
                    t.column formtable.GetCellDBFieldName(row, col).downcase, :string, {:limit=>cell.GetTextWidth}
                  else
                    t.column formtable.GetCellDBFieldName(row, col).downcase, :string, {:limit=>100}
                  end     
                elsif cell.GetDataType == 3 #CCell.CtDate
                  t.column formtable.GetCellDBFieldName(row, col).downcase, :datetime
                end     	     
              end
            end
          end
        end
        
      end
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @ytwg_template = YtwgTemplate.find(params[:id])
  end

  def update
    @ytwg_template = YtwgTemplate.find(params[:id])
    if @ytwg_template.update_attributes(params[:ytwg_template])
      flash[:notice] = 'YtwgTemplate was successfully updated.'
      redirect_to :action => 'show', :id => @ytwg_template
    else
      render :action => 'edit'
    end
  end

  def destroy
    YtwgTemplate.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def download
    template = YtwgTemplate.find(params[:id])
    send_data template.content, :filename=>EncodeUtil.change("GB2312", "UTF-8", template.name)
  end
end
