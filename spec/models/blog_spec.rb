# == Schema Information
#
# Table name: blogs
#
#  id                    :bigint           not null, primary key
#  author                :string
#  email                 :string
#  married_life_duration :string
#  partner               :string
#  slug                  :string
#  started_at            :datetime
#  status                :integer          default("pending")
#  story                 :text
#  story_type            :integer          default("success_story")
#  title                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_blogs_on_slug  (slug) UNIQUE
#

require 'rails_helper'

RSpec.describe Blog, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
