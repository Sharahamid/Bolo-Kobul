class CreateCustomerSupportReplies < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_support_replies do |t|
      t.belongs_to :customer_support, null: false, foreign_key: true
      t.string :repliable_type
      t.integer :repliable_id
      t.string :message

      t.timestamps
    end
  end
end
