class CreateFamilyMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :family_members do |t|
      t.integer :marriage_profile_id
      t.integer :relation
      t.string :name
      t.integer :occupation
      t.integer :residence_type
      t.string :description


      t.timestamps
    end
  end
end
