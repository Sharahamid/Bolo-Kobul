class AddProfileViewButterfliesAndChatButterfliesToConfigurations < ActiveRecord::Migration[6.0]
  def change
    add_column :configurations, :profile_view_butterflies, :integer, default: 0
    add_column :configurations, :chat_butterflies, :integer, default: 0
  end
end
