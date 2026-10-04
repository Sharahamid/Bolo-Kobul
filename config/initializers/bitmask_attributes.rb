# bitmask_attributes loads ActiveRecord as soon as it is required, before the app's
# code can be autoloaded. Load it only when ActiveRecord itself loads.
ActiveSupport.on_load(:active_record) do
  require 'bitmask_attributes'
end
