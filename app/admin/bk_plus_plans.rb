# BK+ plans: price, length and bonus butterflies for each plan
ActiveAdmin.register BkPlusPlan, as: 'BK Plus Plan' do
  menu parent: 'Manage Site', label: 'BK+ Plans'
  permit_params :days, :price, :butterflies, :position, :active
  config.sort_order = 'position_asc'
  config.filters = false

  index do
    column('Plan') { |plan| plan.label_en }
    column('Price (৳)') { |plan| plan.price.to_i }
    column :days
    column('Bonus butterflies', &:butterflies)
    column('Per week (৳)', &:price_per_week)
    column('On sale') { |plan| status_tag(plan.active ? 'Yes' : 'No', class: plan.active ? 'yes' : 'no') }
    column('Sold') { |plan| plan.orders.where(status: :success).count }
    column :position
    actions
  end

  show do
    attributes_table do
      row('Plan') { |plan| plan.label_en }
      row('Price (৳)') { |plan| plan.price.to_i }
      row :days
      row('Bonus butterflies', &:butterflies)
      row('On sale') { |plan| plan.active ? 'Yes' : 'No' }
      row :position
      row('Times bought') { |plan| plan.orders.where(status: :success).count }
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :days, label: 'Length in days (7 = 1 week, 30 = 1 month, 365 = 1 year)'
      f.input :price, label: 'Price in Taka'
      f.input :butterflies, label: 'Bonus butterflies given with this plan'
      f.input :position, label: 'Order on the BK+ page (1 shows first)'
      f.input :active, label: 'On sale (untick to hide this plan)'
    end
    f.actions
  end
end
