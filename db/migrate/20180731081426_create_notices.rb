class CreateNotices < ActiveRecord::Migration[5.2]
  def change
    create_table :notices do |t|
      t.string:title
      t.string:content
      t.string:writer
      t.datetime:date
      t.integer:view
      t.integer:scrap_count
      t.string:link
      t.belongs_to :group
      t.timestamps
    end
  end
end
