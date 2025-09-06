class AddDrinkerAndSmokerToLifeStyles < ActiveRecord::Migration[6.0]
  def change
    add_column :life_styles, :drinker, :integer
    add_column :life_styles, :smoker, :integer
  end
end
