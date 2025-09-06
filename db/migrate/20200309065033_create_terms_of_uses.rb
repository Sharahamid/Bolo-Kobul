class CreateTermsOfUses < ActiveRecord::Migration[6.0]
  def change
    create_table :terms_of_uses do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
