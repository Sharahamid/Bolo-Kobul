ActiveAdmin.register Order do
  actions :index, :show, :edit, :update
  menu parent: 'Reports', priority: 9
  # Only the team's follow-up can be changed here; payment details stay as they were
  permit_params :fulfilment_status, :fulfilment_note
  config.batch_actions = false

  filter :profile_id_eq, as: :string, label: 'Profile ID (BK…)'
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

  form do |f|
    f.inputs "Follow-up for order ##{f.object.id} (#{f.object.assisted_service&.name || f.object.product})" do
      f.input :fulfilment_status, as: :select, collection: Order::FULFILMENT_STATUSES.invert, include_blank: false, label: 'Follow-up status'
      f.input :fulfilment_note, label: 'Team note', hint: 'Only visible to admins, e.g. "Called on 14 Nov, documents received"'
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row('Item') { |o| o.bk_plus? ? "BK+ #{o.bk_plus_plan&.label_en}" : (o.assisted_service? ? o.assisted_service&.name : "#{o.quantity} butterflies") }
      row :total_amount
      row :status
      row :txn_no
      row :created_at
      if resource.assisted_service?
        row('Follow-up status') { |o| Order::FULFILMENT_STATUSES[o.fulfilment_status] }
        row('Team note') { |o| o.fulfilment_note }
        row('Done on') { |o| o.fulfilled_at }
      end
    end
  end

  controller do
    def update
      super do |success, _failure|
        # Back to the Assisted Services list, where follow-ups are managed
        success.html { redirect_to(resource.assisted_service? ? shaheer10inara20_assisted_service_orders_path : resource_path, notice: 'Follow-up saved.') }
      end
    end
  end
end
