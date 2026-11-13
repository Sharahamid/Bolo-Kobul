ActiveAdmin.register Order do
  actions :index, :show
  config.batch_actions = false

  filter :product, as: :select, collection: -> { Order.products }
  filter :status, as: :select, collection: -> { Order.statuses }
  filter :user_email, as: :string, label: 'Member email'
  filter :txn_no
  filter :created_at

  index do
    selectable_column
    id_column
    column :user
    column :quantity
    column :product
    column('Item') do |o|
      if o.bk_plus? then "BK+ #{o.bk_plus_plan&.label_en}"
      elsif o.assisted_service? then o.assisted_service&.name
      else "#{o.quantity} butterflies"
      end
    end
    column :price
    column :total_amount
    column :status
    column :payment_method
    column :txn_no
    column :created_at
  end
end
