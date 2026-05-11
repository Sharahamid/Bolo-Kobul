class ChangeIssueTypeToBeStringInCustomerSupports < ActiveRecord::Migration[6.0]
  def change
    change_column :customer_supports, :issue_type, :string
  end
end
