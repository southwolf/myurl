class CreateArticletemplate < ActiveRecord::Migration
  def self.up
    create_table :ytapl_article_template, :primary_key => :id do |t|
       t.column :taskid, :string, :limit=>100, :null=>true
       t.column :publishtime, :datetime
       t.column :name, :string, :limit=>100, :null=>true
       t.column :context, $TEXT
    end
  end

  def self.down
    drop_table :ytapl_article_template
  end
end
