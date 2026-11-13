# A personal message from the Bolo Kobul team (written in Admin > Users > Edit), shown to the
# member as a pop-up the next time they open the site, until they press the button.
class AddAdminMessageToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin_message, :text
    add_column :users, :admin_message_action, :string
    add_column :users, :admin_message_sent_at, :datetime
    add_column :users, :admin_message_seen_at, :datetime
  end
end
