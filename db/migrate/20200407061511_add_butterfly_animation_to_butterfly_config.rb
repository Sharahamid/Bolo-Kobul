class AddButterflyAnimationToButterflyConfig < ActiveRecord::Migration[6.0]
  def change
    add_column :butterfly_configs, :butterfly_animation, :boolean,
               default: false
  end
end
