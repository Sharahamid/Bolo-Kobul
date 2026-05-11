ActiveAdmin.register Order do
  actions :index, :show
  config.batch_actions = false

  index do
    selectable_column
    id_column
    column :user
    column :quantity
    column :product
    column :price
    column :total_amount
    column :status
    column :payment_method
    column :txn_no
    column :created_at
  end
end
