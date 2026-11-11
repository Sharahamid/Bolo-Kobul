# A BK+ plan: how many days it lasts, its price and its bonus butterflies
# (Admin > BK+ Plans)
class BkPlusPlan < ApplicationRecord
  has_many :orders, dependent: :nullify

  validates :days, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }
  validates :butterflies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :for_sale, -> { where(active: true).order(:position, :days) }

  # "1 Week" / "1 Month" / "1 Year" / "45 Days" in the current language
  def label
    case days
    when 7 then I18n.t('bkx.plus.plan_week')
    when 30, 31 then I18n.t('bkx.plus.plan_month')
    when 365, 366 then I18n.t('bkx.plus.plan_year')
    else I18n.t('bkx.plus.plan_days', n: days)
    end
  end

  # English label, for notifications and texts (saved in English and translated on display)
  def label_en
    I18n.with_locale(:en) { label }
  end

  # Price per week, to compare plans
  def price_per_week
    (price.to_f / days * 7).round
  end

  def to_s
    "#{label} – ৳#{price.to_i} (#{butterflies} butterflies)"
  end
end
