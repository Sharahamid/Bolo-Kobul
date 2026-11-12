# Undo script/bk_plus_pages.rb using the backup it saved.
require "json"
file = File.expand_path("~/bk_plus_pages_backup.json")
data = JSON.parse(File.read(file))
ActiveRecord::Base.transaction do
  data["records"].each { |r| m = r["model"].constantize; a = r["attrs"]; m.find(a["id"]).update_columns(a.except("id")) }
  data["created"].each { |model, id| model.constantize.where(id: id).delete_all }
end
puts "Restored #{data["records"].size} pages and removed #{data["created"].size} new sections."
