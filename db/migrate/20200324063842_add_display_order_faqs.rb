class AddDisplayOrderFaqs < ActiveRecord::Migration[6.0]
  def change
    add_column :faqs, :display_order, :integer, default: 0
  end
end
