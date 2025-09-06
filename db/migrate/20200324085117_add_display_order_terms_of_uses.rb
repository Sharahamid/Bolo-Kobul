class AddDisplayOrderTermsOfUses < ActiveRecord::Migration[6.0]
  def change
    add_column :terms_of_uses, :display_order, :integer, default: 0
  end
end
