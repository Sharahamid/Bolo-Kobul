class AddRefferelPromoCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :refferel_promo_code, :string
  end
end
