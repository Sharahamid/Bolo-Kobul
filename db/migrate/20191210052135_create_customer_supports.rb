class CreateCustomerSupports < ActiveRecord::Migration[6.0]
  def change
    create_table :customer_supports do |t|
      t.integer :marriage_profile_id
      t.string :email
      t.integer :issue_type
      t.text :description

      t.timestamps
    end
  end
end
