class DropConfigurationsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :configurations
  end
end
