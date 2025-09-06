class ChangeNameToBeStringInIssueTypes < ActiveRecord::Migration[6.0]
  def change
    change_column :issue_types, :name, :string
  end
end
