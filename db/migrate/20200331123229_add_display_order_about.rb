class AddDisplayOrderAbout < ActiveRecord::Migration[6.0]
  def change
    add_column :abouts, :display_order, :integer, default: 0
  end
end
