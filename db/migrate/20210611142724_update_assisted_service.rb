class UpdateAssistedService < ActiveRecord::Migration[6.0]
  def change
    add_column :assisted_services, :name, :string
    add_column :assisted_services, :price, :decimal, default: 0.0
    rename_column :assisted_services, :title, :page_title
    rename_column :assisted_services, :detail, :page_content
  end
end
