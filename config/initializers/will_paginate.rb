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

# Fewer page numbers so the row fits on a phone: 1 … 4 5 6 … 20
require 'will_paginate/view_helpers'
WillPaginate::ViewHelpers.pagination_options[:inner_window] = 1
WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0
