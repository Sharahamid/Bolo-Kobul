# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  advanced_search         :integer          default("disabled")
#  block_butterfly_number  :integer
#  butterfly_number        :integer
#  confirmation_sent_at    :datetime
#  confirmation_token      :string
#  confirmed_at            :datetime
#  country_code            :string           default(""), not null
#  created_for             :integer
#  current_sign_in_at      :datetime
#  current_sign_in_ip      :inet
#  deactivated             :boolean          default(FALSE)
#  email                   :string           default(""), not null
#  encrypted_password      :string           default(""), not null
#  failed_attempts         :integer          default(0), not null
#  identification_document :string
#  is_reference            :boolean          default(FALSE)
#  last_sign_in_at         :datetime
#  last_sign_in_ip         :inet
#  locked_at               :datetime
#  name                    :string           default(""), not null
#  otp                     :string
#  phone_number            :string           default(""), not null
#  provider                :string
#  refferel_code           :string
#  refferel_promo_code     :string
#  remember_created_at     :datetime
#  reset_password_sent_at  :datetime
#  reset_password_token    :string
#  sign_in_count           :integer          default(0), not null
#  slug                    :string
#  text_alert              :integer          default("off")
#  uid                     :string
#  unconfirmed_email       :string
#  unlock_token            :string
#  username                :string
#  verified                :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  authy_id                :integer
#  national_id             :string           default(""), not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_slug                  (slug) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

#TODO: should have user type field
class User < ApplicationRecord
  #
  # enum, constant & attr
  include UserConcern
  enum created_for: %i[self parents sibling relative friend colleague children other_as_matchmaker]
  enum text_alert: %i[off on]
  enum advanced_search: %i[disabled enabled]

  attr_writer :login
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Names in non-Latin scripts (e.g. Bangla) produce an empty slug; fall back to a random one
  def normalize_friendly_id(value)
    super.presence || "user-#{SecureRandom.alphanumeric(8).downcase}"
  end

  #
  # Devise configuration
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :omniauthable, :validatable, omniauth_providers: %i[facebook google_oauth2], authentication_keys: [:login]

  # TODO: need to add all the remaining associations
  #
  # Associations
  #

  has_many :marriage_profiles, dependent: :destroy
  has_many :customer_supports, dependent: :destroy
  has_one :advertiser_profile, dependent: :destroy
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy
  has_many :orders
  #
  # validations
  #

  # From Devise module Validatable
  validates_presence_of :created_for, :name, :email, :phone_number
  validate :name_not_spam

  def name_not_spam
    if name.present? && name.match?(/\A[A-Z]{8,}\z/)
      Rails.logger.warn("[BOT BLOCKED - Name Filter] #{Time.current} | Name: #{name} | Email: #{email}")
      BlockedRegistrationAttempt.create(name: name, email: email, phone: phone_number, attempt_type: "name_filter", ip_address: nil)
      errors.add(:name, "is invalid")
    end
  end

  # Letters in any script (e.g. Bangla) plus common name punctuation: - . ' ( ) ,
  validates :name, length: { minimum: 2, maximum: 50 },
                   format: { with: /\A[\p{L}\p{M}\s\-\.'(),]+\z/u, message: 'should only contain letters, spaces and - . \' ( ) ,' }
  validate :name_looks_real

  def name_looks_real
    return if name.blank?
    # Single-word English names must have a reasonable vowel ratio (catches bot strings
    # like "xKqzPwt"); multi-word names are skipped so abbreviations like "Md Shfqt" pass
    vowels = name.count('aeiouAEIOU').to_f
    letters = name.count('a-zA-Z').to_f
    if letters > 4 && !name.strip.include?(' ') && (vowels / letters) < 0.15
      errors.add(:name, 'does not appear to be a real name')
      return
    end
    # No random mixed case (e.g. sUlIYyFQLU) - check for 3+ alternating cases
    if name.match?(/[a-z][A-Z][a-z][A-Z][a-z][A-Z]/) || name.match?(/[A-Z][a-z][A-Z][a-z][A-Z][a-z]/)
      errors.add(:name, 'does not appear to be a real name')
      return
    end
    # Name should have at least one space for full name, or be a short single name
    if name.length > 20 && !name.include?(' ')
      errors.add(:name, 'please enter your full name')
    end
  end
  validates_uniqueness_of :email, :phone_number
  validate :phone_number_not_spam

  def phone_number_not_spam
    return unless phone_number.present?
    digits = phone_number.to_s.gsub(/[^0-9]/, '')
    # Must have between 7 and 15 digits
    if digits.length < 7 || digits.length > 15
      errors.add(:phone_number, "is invalid")
      return
    end
    # Block obviously fake numbers (all same digit like 1111111111)
    if digits.chars.uniq.length == 1
      errors.add(:phone_number, "is invalid")
      return
    end
    # Block sequential numbers like 1234567890
    if digits == digits.chars.each_cons(2).all? { |a, b| b.to_i == a.to_i + 1 }.to_s
      errors.add(:phone_number, "is invalid")
    end
  end
  validates_uniqueness_of :refferel_promo_code,
                          unless: -> { refferel_promo_code.nil? }
  validate :password_regex

  #
  # callbacks
  #

  before_create :generate_refferel_code, :set_otp
  before_save :downcase_email
  after_create :give_default_butterfly

  #
  # instance methods
  #

  def earn_bf_by_reference(referral_promo_code)
    referred_by_user = User.where.not(id: self.id).find_by(refferel_code: referral_promo_code)
    referred_to_user = User.find_by(refferel_promo_code: referral_promo_code)
    if referred_by_user.present? && !referred_to_user.present?
      self.refferel_promo_code = referral_promo_code
      if self.save
        self.give_bf_to_referral(referred_by_user)
        return "Promo code updated successfully"
      else
        return "#{self.errors.full_messages.first}"
      end
    elsif referred_by_user.present? && !referred_by_user.is_reference.present? && referred_to_user.present?
      self.give_bf_to_referral(referred_by_user)
    else
      return "Promo code invalid. Please try another"
    end
  end

  def give_bf_to_referral(referred_by_user)
    if self.marriage_profiles.present? && self.marriage_profiles.pluck(:profile_completeness).include?(100)
      referred_by_user.update(butterfly_number: referred_by_user.butterfly_number + 1)
      referred_by_user.notifications.create(
        content: "You have received a butterfly from #{self.name} through a referral!",
        notifiable: self
      )
    end
  end

  def login
    @login || self.phone_number || self.email
  end

  def generate_refferel_code
    self.refferel_code = SecureRandom.hex(2)
  end
  #
  # Class Methods
  #

  def self.deactivated_users_profile_ids
    deactivated_users_profile_ids = User.where(deactivated:true)&.map{|u| u.marriage_profiles}.flatten.compact.map(&:id)
      # deactivated_users_profiles = deactivated_users_profile_ids.present? ? MarriageProfile.where.not(id: deactivated_users_profile_ids) : []
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      #user.image = auth.info.image # assuming the user model has an image
      # user.skip_confirmation!
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(phone_number) = :value OR lower(email) = :value", {:value => login.downcase}]).first
    else
      if conditions[:phone_number].nil?
        where(conditions).first
      else
        where(phone_number: conditions[:phone_number]).first
      end
    end
  end

  # Website: stay signed in for 3 days. Installed app (Current.remember_in_app is set at
  # sign-in): until the member signs out.
  def remember_expires_at
    Current.remember_in_app ? super : 3.days.from_now
  end

  def active_for_authentication?
    verified?
  end

  OTP_VALID_FOR = 10.minutes
  OTP_MAX_ATTEMPTS = 5

  def self.generate_otp
    SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')
  end

  # Checks a verification code: it must match, be under 10 minutes old, and at most
  # 5 guesses are allowed per code. Returns :ok, :wrong, :expired or :too_many_attempts.
  def check_otp(code)
    return :expired if otp.blank? || otp_sent_at.nil? || otp_sent_at < OTP_VALID_FOR.ago

    # Count the guess in the database first (atomic, so parallel guesses all count)
    User.update_counters(id, otp_attempts: 1)
    return :too_many_attempts if User.where(id: id).pick(:otp_attempts).to_i > OTP_MAX_ATTEMPTS

    ActiveSupport::SecurityUtils.secure_compare(otp.to_s, code.to_s.strip) ? :ok : :wrong
  end

  # A code can only be used once
  def clear_otp!
    update_columns(otp: nil, otp_sent_at: nil, otp_attempts: 0)
  end

  # Allows a new code at most once a minute (each one costs an SMS)
  def otp_resend_allowed?
    otp_sent_at.nil? || otp_sent_at < 1.minute.ago
  end

  def send_otp
    update_columns(otp: User.generate_otp, otp_sent_at: Time.current, otp_attempts: 0)
    message = "Welcome to Bolo Kobul! Your verification code is #{otp}. Valid for 10 minutes. Not you? Please contact support@bolokobul.com"
    if phone_number.to_s.start_with?('+880', '01', '008801')
      SmsService.call(phone_number.to_s, message)
      elsif phone_number.to_s.start_with?('+')
      begin
        UserAccountMailer.with(user: self).otp_verification.deliver_now
      rescue => e
        Rails.logger.error "OTP email failed for #{email}: #{e.message}"
      end
    else
      SmsService.call(phone_number.to_s, message)
    end
  end

  private

  def password_regex
    return if password.blank? || password =~ /\A(?=.*\p{L})(?=.*\d).{8,}\z/
    errors.add :password, 'must be at least 8 characters and include a letter and a number'
  end

  def give_default_butterfly
    if created_for == "self"
      self.update(
        butterfly_number: ButterflyConfig.last&.num_of_free_butterfly || 0
      )
    end
  end

  def set_otp
    self.otp = User.generate_otp
  end

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
