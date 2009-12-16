class DatamanagerController < ApplicationController
  def index
    if params[:name]
      YtwgAnontable.set_table_name(params[:name])
      YtwgAnontable.reset_column_information
      @columns = YtwgAnontable.column_names
      @id_field = @columns[0]
      YtwgAnontable.set_primary_key @id_field
      @ytwg_cell_pages, @ytwg_cells = paginate :ytwg_anontable, :per_page => 20, :order=>YtwgAnontable.column_names[0]
    end
  end
  
  def update
    YtwgAnontable.set_table_name(params[:tablename])
    YtwgAnontable.reset_column_information
    YtwgAnontable.set_primary_key params[:key]
    record = YtwgAnontable.find(params[:id])
    record[params[:field]] = EncodeUtil.change("GB2312", "UTF-8", params[:value])
    record.save
    record.reload
    render :text=>record[params[:field]]
  end
  
  def delete
    YtwgAnontable.set_table_name(params[:table])
    YtwgAnontable.reset_column_information
    YtwgAnontable.set_primary_key params[:key]
    record = YtwgAnontable.find(params[:id])
    if record
      record.destroy
    end
    redirect_to :action=>'index', :name=>params[:table]
  end
  
  def execute_sql
    conn = ActiveRecord::Base.connection
    conn.execute(params[:sql])
    redirect_to :action=>'index', :name=>params[:table], :sql=>params[:sql]
  end
end
