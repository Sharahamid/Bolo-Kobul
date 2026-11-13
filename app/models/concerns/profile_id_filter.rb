# Admin filter "Profile ID": type BK0000123, bk123 or 123 (several, separated by commas or
# spaces, also work). Each model says how a profile ID leads to its own rows, e.g. an
# order belongs to the member who owns that profile.
module ProfileIdFilter
  extend ActiveSupport::Concern

  # "BK0000123, bk45 7" -> [123, 45, 7]
  def self.ids_from(text)
    text.to_s.scan(/(?:bk)?\s*0*(\d+)/i).flatten.map(&:to_i).select(&:positive?).uniq.first(50)
  end

  # Members (users) who own the given profiles
  def self.user_ids_from(text)
    MarriageProfile.where(id: ids_from(text)).select(:user_id)
  end

  class_methods do
    # rows_for(text) is written by each model; nothing matches when nothing was recognised
    def profile_id_eq(text)
      return none if ProfileIdFilter.ids_from(text).empty?

      rows_for_profile_id(text)
    end

    def ransackable_scopes(_auth_object = nil)
      super + %i[profile_id_eq]
    end

    # Keep "1" as the text "1" (otherwise the filter reads it as yes/no)
    def ransackable_scopes_skip_sanitize_args
      super + %i[profile_id_eq]
    end
  end
end
