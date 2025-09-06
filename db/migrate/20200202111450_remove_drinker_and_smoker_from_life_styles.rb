class RemoveDrinkerAndSmokerFromLifeStyles < ActiveRecord::Migration[6.0]
  def change

    remove_column :life_styles, :drinker, :boolean

    remove_column :life_styles, :smoker, :boolean
  end
end
