class CreateMarriageInformations < ActiveRecord::Migration[6.0]
  def change
    create_table :marriage_informations do |t|
      t.integer :marriage_profile_id
      t.boolean :have_childrens
      t.integer :no_of_childrens
      t.boolean :want_more_child

      t.timestamps
    end
  end
end
