class CreateAssistedServices < ActiveRecord::Migration[6.0]
  def change
    create_table :assisted_services do |t|
      t.string :title
      t.text :detail

      t.timestamps
    end
  end
end
