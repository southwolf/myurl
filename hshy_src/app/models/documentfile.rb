class Documentfile < ActiveRecord::Base
  set_table_name :document
#  def file=(file_field)
#    self['ÎÄ¼þÃû'] = base_part_of(file_field.original_filename)
#    self.contenttype = file_field.content_type.chomp
#    self.content = file_field.read
#  end
#  
#  def base_part_of(file_name)
#    name = File.basename(file_name)
#    name.gsub(/[^\w._-]/, '')
#  end
  file_column :path
end
