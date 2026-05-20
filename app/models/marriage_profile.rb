# == Schema Information
#
# Table name: marriage_profiles
#
#  id                      :bigint           not null, primary key
#  about_my_self           :text
#  blood_group             :integer
#  date_of_birth           :datetime
#  description             :text
#  email                   :string
#  family_status           :integer
#  family_type             :integer
#  family_values           :integer
#  gender                  :integer
#  height_ft               :integer
#  height_inch             :integer
#  highest_education_level :integer
#  hometown                :text
#  identification_document :string
#  marital_status          :integer
#  name                    :string
#  nid_or_passport         :string
#  photo_1                 :string
#  photo_2                 :string
#  photo_3                 :string
#  present_address         :text
#  present_location        :text
#  profile_completeness    :integer          default(0)
#  profile_image           :string
#  relation                :integer
#  religion                :integer
#  slug                    :string
#  special_circumstances   :text
#  verified                :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#
# Indexes
#
#  index_marriage_profiles_on_slug  (slug) UNIQUE
#

class MarriageProfile < ApplicationRecord

  #
  # enum, constant & attr
  #
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  enum gender: %i[male female other]
  enum marital_status: %i[unmarried widow_or_widower divorced separated married]
  enum family_type: %i[joint_family nuclear_family does_not_matter]
  enum family_values: %i[orthodox traditional moderate liberal does_not_matter], _prefix: :mfv
  enum family_status: %i[middle_Class upper_middle_class rich/affluent does_not_matter], _prefix: :mfs
  enum blood_group: %i[A+ A- B+ B- O+ O- AB+ AB-]
  enum height_ft: %i[0 1 2 3 4 5 6 7 8]
  enum height_inch: %i[0 1 2 3 4 5 6 7 8 9 10 11], _prefix: :inch
  enum religion: %i[islam hinduism christianity buddhism other], _prefix: :mr
  enum highest_education_level: %i[doctorate graduate post_graduate undergraduate intermediate school non_traditional_education diploma other],
       _prefix: :me

  extend FriendlyId
  friendly_id :unique_id, use: :slugged

  attr_accessor :matching_percentage

  #
  # Associations
  #

  belongs_to :user
  # TODO: need to update the below tow associations
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :academic_informations, dependent: :destroy
  has_one :appearance, dependent: :destroy
  has_one :cultural_value, dependent: :destroy
  accepts_nested_attributes_for :cultural_value
  has_many :family_members, dependent: :destroy
  has_one :hobbies_and_interest, dependent: :destroy
  has_one :life_style, dependent: :destroy
  has_one :marriage_information, dependent: :destroy
  has_many :occupations, dependent: :destroy
  has_one :partner_preference, dependent: :destroy
  has_one :privacy_setting, dependent: :destroy
  has_many :suggested_profiles, dependent: :destroy
  has_many :messages, dependent: :destroy, foreign_key: :sender_id
  has_many :chat_room_users, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_users
  has_many :favourites, dependent: :destroy
  # favourites profile for this profile
  has_many :favourite_profiles, through: :favourites, dependent: :destroy
  # profile who made this profile favourites
  has_many :marriage_profiles, through: :favourites, dependent: :destroy
  has_many :chat_friendships, dependent: :destroy
  has_one_attached :nid_image
  has_one_attached :other_supporting_doc

  # Friendship/kobul request management
  has_friendship

  # From Devise module Validatable
  # TODO ADD VALIDATION; Currently not working
  validate :validate_other_supporting_doc
  validates_presence_of :gender,
                        :height_ft,
                        :height_inch,
                        :highest_education_level,
                        :religion,
                        :date_of_birth,
                        :blood_group,
                        :hometown,
                        :identification_document,
                        :nid_or_passport
  validates_uniqueness_of :nid_or_passport

  #
  # Default scopes
  #
  # default_scope where(user_id: '')
  #
  # Scopes
  #

  mount_uploader :profile_image, ProfileImageUploader
  mount_uploader :photo_1, MarriagePhotoUploader
  mount_uploader :photo_2, MarriagePhotoUploader
  mount_uploader :photo_3, MarriagePhotoUploader
  mount_uploader :identification_document, IdentificationDocumentUploader

  scope :accepted_profiles, -> (p) {
    received_ids = Friendship.where(friend_id: p.id, status: 1).pluck(:friendable_id)
    truly_accepted_ids = received_ids.select { |fid|
      Friendship.exists?(friendable_id: p.id, friend_id: fid, status: 1)
    }
    where(id: truly_accepted_ids)
      .where.not(id: p.chat_friendships.map(&:chat_friend_id))
      .where.not(id: User.where(deactivated: true)&.map { |u| u.marriage_profiles }
                         .flatten.compact.map(&:id))
  }

  scope :pending_for, ->(profile) do
    where("(friendable_id = :id OR friend_id = :id) AND status = :status", id: profile.id, status: :pending)
  end

  #
  # callback
  #
  #
  after_create :create_slug, :progress_recalculate, :set_privacy_setting
  after_destroy :remove_chat_friendship
  before_destroy :remove_friendships
  after_save :crop_profile_image, :bf_by_referral_check, :check_progress, :auto_ocr_verify_document

  #
  # instance methods
  #

  def crop_profile_image
    if saved_change_to_attribute?(:profile_image)
      profile_image.recreate_versions! if crop_x.present?
    end
  end

  def bf_by_referral_check
    if self.user.refferel_promo_code.present?
      self.user.earn_bf_by_reference(user.refferel_promo_code)
    end
  end

  def self.requested_profiles(current_active_profile)
    view_requested_profiles = current_active_profile.requested_friends
    chat_requested_profiles = self.where(id: current_active_profile.chat_friendships.where(status: 1).map(&:chat_friend_id))
    chat_accepted_profiles = self.where(id: current_active_profile.chat_friendships.where(status: 2).map(&:chat_friend_id))
    total_requested_profiles = view_requested_profiles + chat_requested_profiles - chat_accepted_profiles
  end

  def friend_chat_request(friend)
    unless self == friend || self.chat_friendships&.where(status: 1).map(&:chat_friend_id)&.include?(friend.id)
      ChatFriendship.create!(marriage_profile_id: self.id, chat_friend_id: friend.id, status: 0)
      ChatFriendship.create!(marriage_profile_id: friend.id, chat_friend_id: self.id, status: 1)
    end
  end

  def accept_chat_request(friend)
    chat_friendships.where(marriage_profile_id: id, chat_friend_id: friend.id).first.update(status: 2)
    friend.chat_friendships.where(marriage_profile_id: friend.id, chat_friend_id: id).first.update(status: 2)
  end

  def decline_chat_request(friend)
    chat_friendships.where(marriage_profile_id: id, chat_friend_id: friend.id)&.first&.destroy
    friend.chat_friendships.where(marriage_profile_id: friend.id, chat_friend_id: id)&.first&.destroy
  end

  def remove_chat_friendship
    ChatFriendship.where(marriage_profile_id: self.id)&.delete_all
    ChatFriendship.where(chat_friend_id: self.id)&.delete_all
  end

  def remove_friendships
    Friendship.where("friendable_id = ? OR friend_id = ?", id, id).destroy_all
  end

  def nid_image_url(size = :normal)
    if nid_image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(nid_image, only_path: true)
    else
      ''
    end
  end

  def other_supporting_doc_url(size = :normal)
    if other_supporting_doc.attached?
      Rails.application.routes.url_helpers.rails_blob_path(other_supporting_doc, only_path: true)
    else
      ''
    end
  end

  def check_progress
    progress_recalculate if identification_document_changed? || about_my_self_changed? || photo_1_changed? || photo_2_changed? || photo_3_changed?
  end

  def progress_recalculate
    percentage = identification_document.present? ? 40 : 20
    percentage += 10 if academic_informations.count > 0
    percentage += 5 if academic_informations.count > 1
    percentage += 10 if occupations.present?
    percentage += 3 if appearance&.present_any?
    percentage += 10 if family_members.count > 0
    percentage += 5 if family_members.count > 1
    percentage += 3 if life_style.present?
    percentage += 4 if hobbies_and_interest.present?
    percentage += 3 if cultural_value.present?
    percentage += 2 if about_my_self?
    percentage += 5 if photo_1.present? || photo_2.present? || photo_3.present?

    update(profile_completeness: percentage)
  end

  def unique_id
    "BK#{id.to_s.rjust(7, '0')}"
  end

  def create_slug
    update!(slug: unique_id)
  end

  def set_privacy_setting
    self.create_privacy_setting(
      date_of_birth: :public,
      height_ft: :public,
      highest_education_level: :public,
      current_occupation: :public,
      physical_status: :public,
      family_values: :public,
      family_type: :public,
      family_status: :public,
      gender: :public
    )
  end

  def age
    if date_of_birth.present?
      now = Time.now.utc.to_date
      now.year - date_of_birth.year - ((now.month > date_of_birth.month ||
          (now.month == date_of_birth.month &&
              now.day >= date_of_birth.day)) ? 0 : 1)
    end
  end

  def preferred_gender
    male? ? 'female' : 'male'
  end

  def gender_translate(gender)
    if gender == 'other'
      'Other'
    else
      gender == 'female' ? 'Bride' : 'Groom'
    end
  end

  def has_bfly_for_profile_view?
    profile_view_butterflies =
        ButterflyConfig.last.present? ?
            ButterflyConfig.last.profile_view_butterflies : 0
    user.butterfly_number.to_i >= profile_view_butterflies
  end

  def has_bfly_for_chatting?
    chat_butterflies =
        ButterflyConfig.last.present? ?
            ButterflyConfig.last.chat_butterflies : 0
    user.butterfly_number.to_i >= chat_butterflies
  end

  def block_butterflies
    profile_view_butterflies =
        ButterflyConfig.last.present? ?
            ButterflyConfig.last.profile_view_butterflies : 0
    user.block_butterfly_number = user.block_butterfly_number.to_i +
        profile_view_butterflies
    user.butterfly_number = user.butterfly_number.to_i - profile_view_butterflies
    user.save!
  end

  def check_butterfly_balance_notification
    count = user.butterfly_number.to_i
    if count == 0
      user.notifications.create(
        content: "You have run out of butterflies! Purchase more to continue exploring and connecting. <a href='/orders/new' style='color:#FFB627;font-weight:600;'>Get More Butterflies →</a>",
        notifiable: user.marriage_profiles.first,
        will_email: false,
        will_sms: false
      )
    elsif count <= 3
      user.notifications.create(
        content: "You only have #{count} #{'butterfly'.pluralize(count)} left. Get more to keep connecting with new profiles! <a href='/orders/new' style='color:#FFB627;font-weight:600;'>Get More Butterflies →</a>",
        notifiable: user.marriage_profiles.first,
        will_email: false,
        will_sms: false
      )
    end
  end

  def use_butterflies
    profile_view_butterflies =
        ButterflyConfig.last.present? ?
            ButterflyConfig.last.profile_view_butterflies : 0
    user.butterfly_number = user.butterfly_number.to_i - profile_view_butterflies
    check_butterfly_balance_notification
    user.save!
  end

  def use_with_blocked_butterflies
    profile_view_butterflies =
        ButterflyConfig.last.present? ?
            ButterflyConfig.last.profile_view_butterflies : 0
    user.block_butterfly_number =
        user.block_butterfly_number.to_i - profile_view_butterflies
    check_butterfly_balance_notification
    user.save!
  end

  def unblock_blocked_butterflies
    profile_view_butterflies = ButterflyConfig.last.present? ?
                                   ButterflyConfig.last.profile_view_butterflies : 0
    user.block_butterfly_number = [user.block_butterfly_number.to_i - profile_view_butterflies, 0].max
    user.butterfly_number = user.butterfly_number.to_i + profile_view_butterflies
    user.save!
  end

  # TODO: Refactor with only one methods each for both chat and friend requests

  def block_butterflies_chat
    chat_butterflies = ButterflyConfig.last.present? ?
                           ButterflyConfig.last.chat_butterflies : 0
    user.block_butterfly_number = user.block_butterfly_number.to_i + chat_butterflies
    user.butterfly_number = user.butterfly_number.to_i - chat_butterflies
    user.save!
  end

  def use_butterflies_chat
    chat_butterflies = ButterflyConfig.last.present? ?
                           ButterflyConfig.last.chat_butterflies : 0
    user.butterfly_number = user.butterfly_number.to_i - chat_butterflies
    check_butterfly_balance_notification
    user.save!
  end

  def use_with_blocked_butterflies_chat
    chat_butterflies = ButterflyConfig.last.present? ?
                           ButterflyConfig.last.chat_butterflies : 0
    user.block_butterfly_number = user.block_butterfly_number.to_i - chat_butterflies
    user.save!
  end

  def unblock_blocked_butterflies_chat
    chat_butterflies = ButterflyConfig.last.present? ?
                           ButterflyConfig.last.chat_butterflies : 0
    user.block_butterfly_number = [user.block_butterfly_number.to_i - chat_butterflies, 0].max
    user.save!
  end

  def current_occupation
    occupations.where(working_currently: true, end_date: nil)&.last&.name if occupations.present?
  end

  def more_view?(viewer)
    true if id == viewer.id ||
        Friendship.where(friendable_id: id, friend_id: viewer.id, status: 1).exists? ||
        chat_view?(viewer) ||
        chat_friendships.where(status: 0).map(&:chat_friend_id).include?(viewer.id) ||
        viewer.chat_friendships.where(status: 0).map(&:chat_friend_id).include?(id)
  end

  def chat_view?(viewer)
    true if chat_friendships&.where(status: 2)&.map(&:chat_friend_id)&.include?(viewer.id)
  end

  def full_view?(viewer)
    true if id == viewer.id
  end


  def nid_image_validation
    if nid_image.attached?
      if nid_image.blob.byte_size > 2000000
        self.nid_image = nil
        errors[:base] << "File size(max 2MB) too large!"
      elsif !nid_image.blob.content_type.starts_with?('image/')
        self.nid_image = nil
        errors[:base] << "Not an acceptable format!"
      end
    end
  end

  def validate_other_supporting_doc
    if other_supporting_doc.attached?
      if other_supporting_doc.blob.byte_size > 2000000
        self.other_supporting_doc = nil
        errors[:base] << "File size(max 2MB) too large!"
      elsif !other_supporting_doc.blob.content_type.starts_with?('image/')
        self.other_supporting_doc = nil
        errors[:base] << "Not an acceptable format!"
      end
    end
  end

  def auto_ocr_verify_document
    return unless identification_document_changed? && identification_document.present?
    return if doc_verification_status == 1
    begin
      result = DocumentOcrService.verify(self)
      case result
      when :verified
        update_column(:doc_verification_status, 1)
      when :unverified
        update_column(:doc_verification_status, 0)
      end
    rescue => e
      Rails.logger.error "OCR auto-verify failed for profile #{id}: #{e.message}"
    end
  end

  def calculate_matching_percentage!(current_profile)
    # Filter: never show bride older than groom
    if self.female? && current_profile.male?
      return self.matching_percentage = 0 if self.date_of_birth.present? && current_profile.date_of_birth.present? && self.date_of_birth < current_profile.date_of_birth
    end
    if self.male? && current_profile.female?
      return self.matching_percentage = 0 if self.date_of_birth.present? && current_profile.date_of_birth.present? && current_profile.date_of_birth < self.date_of_birth
    end

    your_score  = calculate_one_way_score(current_profile, self)
    their_score = calculate_one_way_score(self, current_profile)
    raw_score   = (your_score * 0.9) + (their_score * 0.1)
    self.matching_percentage = [raw_score.round, 100].min
  end

  def calculate_one_way_score(seeker, candidate)
    score = 0
    preference = seeker.partner_preference
    return 0 unless preference

    # Religion — 20pts
    if preference.religion.present? && candidate.religion.present? &&
       preference.religion.include?(candidate.religion.to_sym)
      score += 20
    end

    # Age — 15pts
    if preference.min_age.present? && preference.max_age.present? && candidate.date_of_birth.present?
      candidate_age = ((Time.zone.now - candidate.date_of_birth.to_time) / 1.year.seconds).floor
      if candidate_age >= preference.min_age.to_i && candidate_age <= preference.max_age.to_i
        score += 15
      end
    end

    # Education — 10pts
    if preference.highest_education_level.present? && candidate.highest_education_level.present? &&
       preference.highest_education_level == candidate.highest_education_level
      score += 10
    end

    # Hometown — 8pts
    if preference.hometown.present? && candidate.hometown.present? &&
       preference.hometown.include?(candidate.hometown)
      score += 8
    end

    # Present location — 8pts
    if preference.present_location.present? && candidate.present_location.present? &&
       preference.present_location.include?(candidate.present_location)
      score += 8
    end

    # Marital status — 7pts
    if preference.marital_status.present? && candidate.marital_status.present? &&
       preference.marital_status.include?(candidate.marital_status.to_sym)
      score += 7
    end

    # Height — 5pts
    if preference.min_height.present? && candidate.height_ft.present?
      if (preference.min_height.to_i == candidate.height_ft.to_i && preference.min_inch.to_i <= candidate.height_inch.to_i) ||
         preference.min_height.to_i < candidate.height_ft.to_i
        score += 5
      end
    end

    # Family status — 5pts
    if preference.family_status.present? && candidate.family_status.present? &&
       (preference.fs_does_not_matter? || preference.family_status == candidate.family_status)
      score += 5
    end

    # Blood group — 5pts
    if preference.blood_group.present? && candidate.blood_group.present? &&
       preference.blood_group.include?(candidate.blood_group)
      score += 5
    end

    # Has photo — 5pts
    score += 5 if candidate.photo_1.present?

    # Verified profile — 3pts
    score += 3 if candidate.verified?

    # Recently active last 7 days — 4pts
    if candidate.user.last_sign_in_at.present? &&
       candidate.user.last_sign_in_at >= 7.days.ago
      score += 4
    end

    score
  end
end
