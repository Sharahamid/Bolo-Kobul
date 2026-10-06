ActiveAdmin.register MarketPlaceType do
  menu parent: 'Manage Site'
  permit_params :name, :display_order
  config.sort_order = 'display_order_asc'

  index do
    selectable_column
    id_column
    column :name
    column('Display order (Wedding Shopping menu)', &:display_order)
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :display_order, hint: 'Smaller numbers come first in the Wedding Shopping menu (1 = first)'
    end
    f.actions
  end
end
