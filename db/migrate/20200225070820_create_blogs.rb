class CreateBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :blogs do |t|
      t.string :title
      t.string :email
      t.integer :status, default: 0
      t.string :author
      t.string :partner
      t.string :first_meet
      t.datetime :started_at
      t.datetime :wedding_date
      t.text :story
      t.timestamps
    end
  end
end
