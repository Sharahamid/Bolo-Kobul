# == Schema Information
#
# Table name: butterfly_configs
#
#  id                       :bigint           not null, primary key
#  adv_search_butterflies   :integer          default(0)
#  butterfly_animation      :boolean          default(FALSE)
#  butterfly_price          :float            default(0.0)
#  chat_butterflies         :integer          default(0)
#  max_marriage_profiles    :integer          default(5)
#  num_of_free_butterfly    :integer          default(0)
#  profile_view_butterflies :integer          default(0)
#  text_alert_butterflies   :integer          default(0)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'rails_helper'

RSpec.describe ButterflyConfig, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
