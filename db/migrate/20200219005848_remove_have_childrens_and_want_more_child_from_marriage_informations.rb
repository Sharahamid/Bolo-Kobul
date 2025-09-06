class RemoveHaveChildrensAndWantMoreChildFromMarriageInformations < ActiveRecord::Migration[6.0]
  def change

    remove_column :marriage_informations, :have_childrens, :boolean

    remove_column :marriage_informations, :want_more_child, :boolean
  end
end
