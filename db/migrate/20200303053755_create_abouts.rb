class CreateAbouts < ActiveRecord::Migration[6.0]
  def change
    create_table :abouts do |t|
      t.text :content
      t.integer :content_type

      t.timestamps
    end
  end
end
