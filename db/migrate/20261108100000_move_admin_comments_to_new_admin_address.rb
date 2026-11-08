# The admin area moved from /shefali007 to /shaheer10inara20. Admin notes ("comments")
# are filed under the admin area's name, so move them along with it.
class MoveAdminCommentsToNewAdminAddress < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE active_admin_comments SET namespace = 'shaheer10inara20' WHERE namespace = 'shefali007'"
  end

  def down
    execute "UPDATE active_admin_comments SET namespace = 'shefali007' WHERE namespace = 'shaheer10inara20'"
  end
end
