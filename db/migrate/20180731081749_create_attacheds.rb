class CreateAttacheds < ActiveRecord::Migration[5.2]
  def change
    create_table :attacheds do |t|
      t.string :link
      t.string :name
      t.belongs_to :notice
      t.timestamps
    end
  end
end
