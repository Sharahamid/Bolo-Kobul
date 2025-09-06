class AddDressStyleToLifeStyles < ActiveRecord::Migration[6.0]
  def change
    add_column :life_styles, :dress_style, :string
  end
end
