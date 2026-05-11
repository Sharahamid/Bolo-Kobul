class ChangesColumnsToBlogs < ActiveRecord::Migration[6.0]
  def change
    remove_column :blogs, :first_meet, :string
    remove_column :blogs, :wedding_date, :datetime
    add_column :blogs, :married_life_duration, :string
  end
end
