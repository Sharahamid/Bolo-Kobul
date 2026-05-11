class AddStoryTypeToBlog < ActiveRecord::Migration[6.0]
  def change
    add_column :blogs, :story_type, :integer, default: 0
  end
end
