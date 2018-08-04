class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.string :link
      t.belongs_to :notice
      t.timestamps
    end
  end
end
