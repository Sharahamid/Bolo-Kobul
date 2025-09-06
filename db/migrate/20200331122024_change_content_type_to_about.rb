class ChangeContentTypeToAbout < ActiveRecord::Migration[6.0]
  def up
    change_column :abouts, :content_type, :string
  end
end
