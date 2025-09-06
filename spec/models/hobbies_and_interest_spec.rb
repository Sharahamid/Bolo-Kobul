# == Schema Information
#
# Table name: hobbies_and_interests
#
#  id                     :bigint           not null, primary key
#  cuisine                :text
#  favourite_book         :string
#  favourite_movie        :text
#  favourite_song         :string
#  favourite_sports_show  :text
#  favourite_tv_show      :text
#  fitness_activity       :text
#  hobby                  :text
#  interest               :text
#  music                  :text
#  music_type             :text
#  read                   :text
#  reading_type           :text
#  specific_entertainment :string
#  travel                 :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  marriage_profile_id    :integer
#

require 'rails_helper'

RSpec.describe HobbiesAndInterest, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
