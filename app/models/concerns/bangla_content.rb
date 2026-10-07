# Text written by the admin can have a Bangla version in a matching "_bn" column.
# On Bangla pages the Bangla version is shown when it is filled in, otherwise the
# English one. The admin panel is always English, so it edits both separately.
#
#   class Faq < ApplicationRecord
#     include BanglaContent
#     bangla_fields :title, :content
#   end
module BanglaContent
  extend ActiveSupport::Concern

  class_methods do
    def bangla_fields(*names)
      names.each do |name|
        define_method(name) do
          bangla = I18n.locale == :bn ? self["#{name}_bn"] : nil
          bangla.presence || super()
        end
      end
    end
  end
end
