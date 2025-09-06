class RemoveDressStyleFromLifeStyles < ActiveRecord::Migration[6.0]
  def change
    remove_column :life_styles, :dress_style, :integer
  end
end
