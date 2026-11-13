# Notifications already saved with "Best of Luck! <3" now end with a gold heart, wherever
# they are shown (bell list, admin, emails)
class ReplaceHeartTextInNotifications < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE notifications
      SET content = regexp_replace(content, 'Best of Luck! (<3|&lt;3)', 'Best of luck! 💛', 'g')
      WHERE content LIKE '%Best of Luck! <3%' OR content LIKE '%Best of Luck! &lt;3%'
    SQL
  end

  def down; end
end
