class AddHaveChildrensAndWantMoreChildToMarriageInformations < ActiveRecord::Migration[6.0]
  def change
    add_column :marriage_informations, :have_children, :boolean
    add_column :marriage_informations, :want_more_child, :boolean
  end
end
