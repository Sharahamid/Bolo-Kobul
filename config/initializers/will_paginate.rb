# will_paginate and ActiveAdmin's kaminari both paginate records: give will_paginate's
# relations the method names kaminari uses, once ActiveRecord has loaded
ActiveSupport.on_load(:active_record) do
  require 'will_paginate/active_record'

  WillPaginate::ActiveRecord::RelationMethods.module_eval do
    alias_method :per, :per_page
    alias_method :num_pages, :total_pages
  end

  ActiveRecord::Relation.class_eval do
    alias_method :total_count, :count
  end
end
