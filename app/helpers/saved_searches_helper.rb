module SavedSearchesHelper
  # A short name for a search, from its filters: "25–30 years · Islam · Dhaka"
  def saved_search_default_name(criteria)
    parts = []
    from, to = criteria['age_from'], criteria['age_to']
    if from || to
      ages = [from, to].compact.map { |age| local_digits(age) }.join('–')
      parts << t('saved_search.ages', ages: ages)
    end
    parts << religion_label(criteria['religion']) if criteria['religion']
    parts << district_label(criteria['hometown']) if criteria['hometown']
    extra = SavedSearch::LIST_KEYS.sum { |key| Array(criteria[key]).size }
    parts << t('saved_search.more_filters', count: local_digits(extra)) if extra.positive?
    parts.join(' · ').first(60).presence || t('saved_search.my_search')
  end
end
