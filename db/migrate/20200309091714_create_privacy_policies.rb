class CreatePrivacyPolicies < ActiveRecord::Migration[6.0]
  def change
    create_table :privacy_policies do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
