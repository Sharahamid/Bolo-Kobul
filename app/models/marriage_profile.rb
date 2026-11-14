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
  # Admin filter "Profile ID" (see ProfileIdFilter)
  include ProfileIdFilter
  def self.rows_for_profile_id(text)
    where(id: ProfileIdFilter.ids_from(text))
  end


  #
  # enum, constant & attr
  #
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  enum :gender, %i[male female other]
  enum :marital_status, %i[unmarried widow_or_widower divorced separated married]
  # Statuses members can choose ("married" and "separated" are kept only for older data)
  SELECTABLE_MARITAL_STATUSES = %w[divorced unmarried widow_or_widower].freeze
  enum :family_type, %i[joint_family nuclear_family does_not_matter]
  enum :family_values, %i[orthodox traditional moderate liberal does_not_matter], prefix: :mfv
  enum :family_status, %i[middle_Class upper_middle_class rich/affluent does_not_matter], prefix: :mfs
  enum :blood_group, %i[A+ A- B+ B- O+ O- AB+ AB-]
  enum :height_ft, %i[0 1 2 3 4 5 6 7 8]
  enum :height_inch, %i[0 1 2 3 4 5 6 7 8 9 10 11], prefix: :inch
  enum :religion, %i[islam hinduism christianity buddhism other], prefix: :mr
  enum :highest_education_level, %i[doctorate graduate post_graduate undergraduate intermediate school non_traditional_education diploma other],
       prefix: :me

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
  has_many :saved_searches, -> { order(:created_at) }, dependent: :destroy
  has_many :messages, dependent: :destroy, foreign_key: :sender_id
  has_many :chat_room_users, dependent: :destroy
  has_many :chat_rooms, through: :chat_room_users
  # A private chat dies with either member: remove it before this profile's links to it go
  before_destroy :remove_private_chat_rooms, prepend: true

  # Chats that still have another member (the other profile may have been deleted)
  def active_chat_rooms
    # Chats with someone either side has blocked are hidden everywhere
    blocked_ids = HasFriendship::Friendship.where(friendable_type: 'MarriageProfile', friendable_id: id, status: 3).select(:friend_id)
    # ...and chats whose other member's profile has since been deleted are left out
    chat_rooms.where(id: ChatRoomUser.where.not(marriage_profile_id: id).where(marriage_profile_id: MarriageProfile.select(:id)).select(:chat_room_id))
              .where.not(id: ChatRoomUser.where(marriage_profile_id: blocked_ids).select(:chat_room_id))
  end
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
  validate :identification_document_size
  validate :at_least_18, if: -> { date_of_birth_changed? || gender_changed? }
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
  # The member's own biodata, if they uploaded one on the Basics step (admin-only)
  mount_uploader :biodata_document, BiodataUploader

  # Both sides accepted the 1st Kobul and aren't chatting yet (includes 2nd Kobuls sent or received)
  scope :accepted_profiles, -> (p) {
    received_ids = Friendship.where(friend_id: p.id, status: 1).pluck(:friendable_id)
    truly_accepted_ids = received_ids.select { |fid|
      Friendship.exists?(friendable_id: p.id, friend_id: fid, status: 1)
    }
    where(id: truly_accepted_ids)
      .where.not(id: p.chat_friendships.where(status: 2).map(&:chat_friend_id))
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
  before_validation :keep_registered_name
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

  # 1st Kobuls this profile has received and not answered yet. Sending one creates
  # sender->receiver as pending (0) and receiver->sender as 1; accepting sets both to 1
  # and rejecting deletes both, so only unanswered ones still have the pending row.
  def self.requested_profiles(current_active_profile)
    where(id: Friendship.where(friend_id: current_active_profile.id, status: 0).select(:friendable_id))
      .where.not(id: User.deactivated_users_profile_ids)
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

  # Blocks another profile, whether or not a Kobul was ever exchanged: both sides stop
  # seeing each other in lists and search, and their chat closes
  def block_profile!(other)
    return if other.nil? || other.id == id

    transaction do
      [[self, other], [other, self]].each do |one, two|
        friendship = HasFriendship::Friendship.find_or_initialize_by(friendable_type: 'MarriageProfile', friendable_id: one.id, friend_id: two.id)
        friendship.update_columns(status: 3, blocker_id: id, updated_at: Time.current) if friendship.persisted?
        if friendship.new_record?
          HasFriendship::Friendship.insert({ friendable_type: 'MarriageProfile', friendable_id: one.id, friend_id: two.id,
                                             status: 3, blocker_id: id, created_at: Time.current, updated_at: Time.current })
        end
      end
      ChatFriendship.where(marriage_profile_id: id, chat_friend_id: other.id)
                    .or(ChatFriendship.where(marriage_profile_id: other.id, chat_friend_id: id))
                    .update_all(status: ChatFriendship.statuses[:blocked])
      Favourite.where(marriage_profile_id: id, favourite_profile_id: other.id)
               .or(Favourite.where(marriage_profile_id: other.id, favourite_profile_id: id)).delete_all
    end
  end

  # Only the member who blocked can unblock
  def unblock_profile!(other)
    return false unless blocked_by_me?(other)

    transaction do
      HasFriendship::Friendship.where(friendable_type: 'MarriageProfile', status: 3)
                               .where('(friendable_id = :a AND friend_id = :b) OR (friendable_id = :b AND friend_id = :a)', a: id, b: other.id)
                               .delete_all
      blocked_chat = ChatFriendship.where(marriage_profile_id: id, chat_friend_id: other.id, status: :blocked)
                                   .or(ChatFriendship.where(marriage_profile_id: other.id, chat_friend_id: id, status: :blocked))
      # If the two were already chatting before the block, reopen that chat (no need to
      # send 2nd Kobuls again); otherwise start over
      already_chatting = ChatRoomUser.where(marriage_profile_id: id).where(
        chat_room_id: ChatRoomUser.where(marriage_profile_id: other.id).select(:chat_room_id)
      ).exists?
      if already_chatting
        blocked_chat.update_all(status: ChatFriendship.statuses[:accepted], updated_at: Time.current)
      else
        blocked_chat.delete_all
      end
    end
    true
  end

  def blocked_by_me?(other)
    HasFriendship::Friendship.exists?(friendable_type: 'MarriageProfile', friendable_id: id, friend_id: other.id, status: 3, blocker_id: id)
  end

  # Either side has blocked the other
  def blocked_with?(other)
    HasFriendship::Friendship.exists?(friendable_type: 'MarriageProfile', friendable_id: id, friend_id: other.id, status: 3)
  end

  # Profiles this profile has blocked (not the ones that blocked it)
  def profiles_i_blocked
    MarriageProfile.where(id: HasFriendship::Friendship.where(friendable_type: 'MarriageProfile', friendable_id: id, status: 3, blocker_id: id).select(:friend_id))
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

  # Members can browse recommendations straight away, but sending a Kobul needs
  # a profile at least this complete
  KOBUL_MIN_COMPLETENESS = 80

  def ready_for_kobul?
    profile_completeness.to_i >= KOBUL_MIN_COMPLETENESS
  end

  # Each part of the profile and the percentage it adds. The ID document counts 40 (20 is
  # given for the Basic form either way, so it adds 20 more). The total is 100.
  def completeness_items
    [
      [:id_document,  20, identification_document.present?],
      [:education,    10, academic_informations.count > 0],
      [:education_2,   5, academic_informations.count > 1],
      [:occupation,   10, occupations.present?],
      [:appearance,    3, appearance&.present_any? || false],
      [:family,       10, family_members.count > 0],
      [:family_2,      5, family_members.count > 1],
      [:life_style,    3, life_style.present?],
      [:hobbies,       4, hobbies_and_interest.present?],
      [:cultural,      3, cultural_value.present?],
      [:about,         2, about_my_self?],
      [:photo,         5, photo_1.present? || photo_2.present? || photo_3.present?]
    ].map { |key, points, done| { key: key, points: points, done: done } }
  end

  # The profile sections still to fill in, in the order they appear on the profile.
  # A second education or family member counts as the same section as the first.
  def sections_to_update
    completeness_items.reject { |item| item[:done] }
                      .map { |item| item[:key].to_s.delete_suffix('_2').to_sym }.uniq
  end

  def progress_recalculate
    percentage = 20 + completeness_items.select { |item| item[:done] }.sum { |item| item[:points] }
    update_column(:profile_completeness, percentage) if persisted? && profile_completeness != percentage
  end

  # A member who registered for themself: their first profile always carries the
  # name they registered with, and it can't be changed on the profile
  # The member's own profile (registered "for myself" and their first profile). Any other
  # profile is for someone else, so forms talk about "the candidate" instead of "you".
  def own_profile?
    own_name_locked?
  end

  def own_name_locked?
    return false unless user&.created_for == "self"
    first_id = user.marriage_profiles.minimum(:id)
    new_record? ? first_id.nil? : first_id == id
  end

  def keep_registered_name
    return unless own_name_locked?
    if new_record?
      self.name = user.name
    elsif will_save_change_to_name?
      self.name = name_in_database
    end
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


  # ID document: 10 MB at most, the same limit the upload field shows (shared/_file_guard)
  def identification_document_size
    return unless identification_document_changed? && identification_document.present?
    size = identification_document.file&.size.to_i
    if size > 10_000_000
      remove_identification_document!
      errors.add(:identification_document, I18n.t('form.file_too_large', mb: 10))
    end
  end

  def nid_image_validation
    if nid_image.attached?
      if nid_image.blob.byte_size > 2000000
        self.nid_image = nil
        errors.add(:base, "File size(max 2MB) too large!")
      elsif !nid_image.blob.content_type.starts_with?('image/')
        self.nid_image = nil
        errors.add(:base, "Not an acceptable format!")
      end
    end
  end

  def validate_other_supporting_doc
    if other_supporting_doc.attached?
      if other_supporting_doc.blob.byte_size > 2000000
        self.other_supporting_doc = nil
        errors.add(:base, "File size(max 2MB) too large!")
      elsif !other_supporting_doc.blob.content_type.starts_with?('image/')
        self.other_supporting_doc = nil
        errors.add(:base, "Not an acceptable format!")
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

  # Match % between this profile and the member looking at it (current_profile).
  #  - 70% how well this profile fits what the member asked for, 30% how well the
  #    member fits what this profile asked for
  #  - anything left as "Doesn't matter" counts as a full match for that item
  #  - near misses get half points (a year or two outside the age range, an inch or
  #    two outside the height range, one education level below)
  #  - a detail the profile has not filled in gets only a third of the points, so
  #    complete profiles rank higher
  #  - must-haves: if this profile clearly fails something the member marked as a
  #    must-have, the % is held at PartnerPreference::MUST_HAVE_CAP
  #  - photo, verified badge, new members and recent activity are not part of the %
  #    (they only decide the order among equal matches, see #match_quality)
  # (age_filter is accepted for older callers and no longer used)
  attr_reader :match_fit, :failed_must_haves, :mutual_match

  MUTUAL_MATCH_THRESHOLD = 80

  def calculate_matching_percentage!(current_profile, age_filter: nil)
    @match_fit   = match_breakdown(current_profile, self)
    their_fit    = match_breakdown(self, current_profile)
    your_score   = score_from_fit(@match_fit)
    their_score  = score_from_fit(their_fit)
    @mutual_match = your_score >= MUTUAL_MATCH_THRESHOLD && their_score >= MUTUAL_MATCH_THRESHOLD

    percent = [(your_score * 0.7 + their_score * 0.3).round, 100].min
    must = Array(current_profile&.partner_preference&.must_haves)
    @failed_must_haves = must.select { |item| @match_fit && @match_fit[item.to_sym] == 0.0 }
    if @failed_must_haves.any?
      percent = [percent, PartnerPreference::MUST_HAVE_CAP].min
      @mutual_match = false
    end
    self.matching_percentage = percent
  end

  # Tie-breaker for profiles with the same match %: photo, verified, new on Bolo Kobul,
  # recently active
  def match_quality
    (photo_1.present? ? 3 : 0) + (verified? ? 2 : 0) +
      (created_at.present? && created_at >= 14.days.ago ? 2 : 0) +
      (user&.last_sign_in_at.present? && user.last_sign_in_at >= 7.days.ago ? 1 : 0)
  end

  # Education levels from lowest to highest, for "Minimum Education Level" in preferences.
  # Levels outside this ladder (non-traditional, other) only match themselves.
  EDUCATION_RANK = %w[school intermediate diploma undergraduate graduate post_graduate doctorate]
                   .each_with_index.to_h.freeze

  def education_at_least?(level, minimum)
    rank = EDUCATION_RANK[level.to_s]
    min_rank = EDUCATION_RANK[minimum.to_s]
    return level.to_s == minimum.to_s if rank.nil? || min_rank.nil?

    rank >= min_rank
  end

  # Points for each item (they add up to 100)
  MATCH_WEIGHTS = { religion: 18, age: 14, marital_status: 10, education: 9, location: 9,
                    height: 7, profession: 7, hometown: 6, relocation: 4, family_values: 4,
                    family_type: 4, family_status: 4, blood_group: 4 }.freeze

  # Points for a detail the other profile has not filled in yet
  UNKNOWN_FIT = 0.33

  # Age range assumed when a member leaves both Min and Max Age blank ("Doesn't matter"):
  #  - a woman: from her own age up to 14 years older (36 -> 36 to 50)
  #  - a man: from 15 years younger up to his own age (36 -> 21 to 36)
  DEFAULT_OLDER_GAP = 14
  DEFAULT_YOUNGER_GAP = 15

  def default_age_range
    own = age_in_years
    return nil if own.nil?

    if gender.to_s == 'male'
      [[own - DEFAULT_YOUNGER_GAP, 18].max, own]
    else
      [own, own + DEFAULT_OLDER_GAP]
    end
  end

  def age_in_years
    return nil if date_of_birth.blank?

    ((Time.zone.now - date_of_birth.to_time) / 1.year.seconds).floor
  end

  # The member's current job (works on already-loaded records, no extra lookups)
  def matching_occupation
    list = occupations.loaded? ? occupations.to_a : occupations.to_a
    list.select { |o| o.working_currently && o.end_date.nil? }.max_by(&:id)&.name
  end

  # How well `candidate` fits what `seeker` asked for, item by item (0.0 - 1.0).
  # Only the items the seeker actually chose are listed; nil = no preferences saved.
  def match_breakdown(seeker, candidate)
    preference = seeker&.partner_preference
    return nil unless preference && candidate

    fit = {}

    # Religion
    wanted = Array(preference.religion).map(&:to_s).reject(&:blank?)
    fit[:religion] = list_fit(wanted, candidate.religion) if wanted.any?

    # Age (either limit may be left open). If both are blank, use #default_age_range
    # rather than every age.
    min_age = preference.min_age.presence&.to_i
    max_age = preference.max_age.presence&.to_i
    min_age, max_age = seeker.default_age_range if min_age.nil? && max_age.nil? && seeker.default_age_range
    if min_age || max_age
      fit[:age] =
        if candidate.date_of_birth.blank? then UNKNOWN_FIT
        else
          age = ((Time.zone.now - candidate.date_of_birth.to_time) / 1.year.seconds).floor
          miss = [min_age ? min_age - age : 0, max_age ? age - max_age : 0, 0].max
          miss.zero? ? 1.0 : (miss <= 2 ? 0.5 : 0.0)
        end
    end

    # Marital status
    wanted = Array(preference.marital_status).map(&:to_s).reject(&:blank?)
    fit[:marital_status] = list_fit(wanted, candidate.marital_status) if wanted.any?

    # Education (a minimum level; one level below gets half)
    if preference.highest_education_level.present?
      fit[:education] =
        if candidate.highest_education_level.blank? then UNKNOWN_FIT
        elsif education_at_least?(candidate.highest_education_level, preference.highest_education_level) then 1.0
        else
          rank = EDUCATION_RANK[candidate.highest_education_level.to_s]
          min_rank = EDUCATION_RANK[preference.highest_education_level.to_s]
          rank && min_rank && min_rank - rank == 1 ? 0.5 : 0.0
        end
    end

    # Where they live now
    wanted = Array(preference.present_location).reject(&:blank?)
    fit[:location] = list_fit(wanted, candidate.present_location) if wanted.any?

    # Height (minimum and maximum; within 2 inches outside gets half)
    min_h = preference.min_height.presence && (preference.min_height.to_i * 12 + preference.min_inch.to_i)
    max_h = preference.max_height.presence && (preference.max_height.to_i * 12 + preference.max_inch.to_i)
    if min_h || max_h
      fit[:height] =
        if candidate.height_ft.blank? then UNKNOWN_FIT
        else
          h = candidate.height_ft.to_i * 12 + candidate.height_inch.to_i
          miss = [min_h ? min_h - h : 0, max_h ? h - max_h : 0, 0].max
          miss.zero? ? 1.0 : (miss <= 2 ? 0.5 : 0.0)
        end
    end

    # Profession
    wanted = Array(preference.occupations).map(&:to_s).reject(&:blank?)
    fit[:profession] = list_fit(wanted, candidate.matching_occupation) if wanted.any?

    # Hometown (and hometowns the seeker excluded)
    excluded = Array(preference.except_hometown).reject(&:blank?)
    wanted = Array(preference.hometown).reject(&:blank?)
    if candidate.hometown.present? && excluded.include?(candidate.hometown)
      fit[:hometown] = 0.0
    elsif wanted.any?
      fit[:hometown] = list_fit(wanted, candidate.hometown)
    end

    # Willing to move after marriage (stored as 0 = Yes, 1 = No)
    if preference.relocation_needed
      answer = candidate.cultural_value&.willing_to_relocate
      fit[:relocation] = answer.nil? ? UNKNOWN_FIT : (answer.to_i.zero? ? 1.0 : 0.0)
    end

    # Family values / type / status ("does_not_matter" = full match, so not listed)
    { family_values: :family_values, family_type: :family_type, family_status: :family_status }.each do |item, attr|
      wanted = preference.public_send(attr)
      next if wanted.blank? || wanted.to_s == 'does_not_matter'

      fit[item] = enum_fit(wanted, candidate.public_send(attr))
    end

    # Blood group
    wanted = Array(preference.blood_group).reject(&:blank?)
    fit[:blood_group] = list_fit(wanted, candidate.blood_group) if wanted.any?

    fit
  end

  # 0-100 from an item-by-item breakdown; items the seeker did not choose count in full.
  # No preferences saved yet: neutral 50.
  def score_from_fit(fit)
    return 50 if fit.nil?

    MATCH_WEIGHTS.sum { |item, points| points * fit.fetch(item, 1.0) }.round
  end

  # Kept for older callers
  def calculate_one_way_score(seeker, candidate)
    score_from_fit(match_breakdown(seeker, candidate))
  end

  # Seeker chose from a list: candidate's value unknown = a third; otherwise in or out
  def list_fit(wanted, value)
    wanted = Array(wanted).map(&:to_s)
    return 1.0 if wanted.empty?
    return UNKNOWN_FIT if value.blank?

    wanted.include?(value.to_s) ? 1.0 : 0.0
  end

  def enum_fit(wanted, value)
    return 1.0 if wanted.blank? || wanted.to_s == 'does_not_matter'
    return UNKNOWN_FIT if value.blank?

    wanted.to_s == value.to_s ? 1.0 : 0.0
  end

  # Minimum age to marry in Bangladesh: 21 for men, 18 for women (and for "other")
  MIN_AGE_MALE = 21
  MIN_AGE = 18

  def self.minimum_age_for(gender)
    gender.to_s == 'male' ? MIN_AGE_MALE : MIN_AGE
  end

  # Bolo Kobul is for adults of marriageable age only (name kept for older references)
  def at_least_18
    return if date_of_birth.blank?

    min = self.class.minimum_age_for(gender)
    return unless date_of_birth.to_date > Date.current.years_ago(min)

    key = min == MIN_AGE_MALE ? 'under_21_male' : 'under_18'
    errors.add(:date_of_birth, I18n.t(own_profile? ? "form.#{key}" : "form.candidate.#{key}"))
  end

  def remove_private_chat_rooms
    ChatRoom.where(id: chat_room_users.select(:chat_room_id), is_private: true).destroy_all
  end

end
