# Turns British spellings into American ones (favourite -> favorite, organise -> organize,
# cancelled -> canceled...). Used for the website's English texts so they all use one
# spelling style. Only whole words from the list below are changed.
module AmericanEnglish
  STEMS = {
    'favour' => 'favor', 'colour' => 'color', 'behaviour' => 'behavior', 'honour' => 'honor',
    'neighbour' => 'neighbor', 'humour' => 'humor', 'rumour' => 'rumor', 'labour' => 'labor',
    'organis' => 'organiz', 'recognis' => 'recogniz', 'personalis' => 'personaliz',
    'customis' => 'customiz', 'prioritis' => 'prioritiz', 'authoris' => 'authoriz',
    'unauthoris' => 'unauthoriz', 'emphasis' => nil, 'minimis' => 'minimiz', 'maximis' => 'maximiz',
    'specialis' => 'specializ', 'finalis' => 'finaliz', 'utilis' => 'utiliz', 'summaris' => 'summariz',
    'optimis' => 'optimiz', 'criticis' => 'criticiz', 'memoris' => 'memoriz', 'characteris' => 'characteriz',
    'apologis' => 'apologiz', 'realis' => 'realiz', 'categoris' => 'categoriz', 'standardis' => 'standardiz',
    'familiaris' => 'familiariz', 'visualis' => 'visualiz', 'synchronis' => 'synchroniz', 'stabilis' => 'stabiliz',
    'analys' => 'analyz', 'paralys' => 'paralyz'
  }.freeze
  # ends allowed after an -is/-ys stem (organise, organised, organising, organisation...)
  IZE_ENDS = %w[e es ed ing ation ations er ers able].freeze
  OUR_ENDS = ['', 's', 'ed', 'ing', 'ite', 'ites', 'ited', 'iting', 'able', 'ably', 'ful', 'ed'].freeze

  WORDS = {
    'cancelled' => 'canceled', 'cancelling' => 'canceling', 'travelled' => 'traveled',
    'travelling' => 'traveling', 'traveller' => 'traveler', 'travellers' => 'travelers',
    'labelled' => 'labeled', 'labelling' => 'labeling', 'modelling' => 'modeling',
    'catalogue' => 'catalog', 'catalogues' => 'catalogs', 'licence' => 'license', 'licences' => 'licenses',
    'defence' => 'defense', 'defences' => 'defenses', 'offence' => 'offense', 'offences' => 'offenses',
    'centre' => 'center', 'centres' => 'centers', 'programme' => 'program', 'programmes' => 'programs',
    'jewellery' => 'jewelry', 'judgement' => 'judgment', 'judgements' => 'judgments', 'grey' => 'gray',
    'ageing' => 'aging', 'whilst' => 'while', 'amongst' => 'among', 'learnt' => 'learned',
    'enrolment' => 'enrollment', 'fulfil' => 'fulfill', 'fulfilment' => 'fulfillment', 'practise' => 'practice',
    'practised' => 'practiced', 'cheque' => 'check', 'cheques' => 'checks', 'pyjamas' => 'pajamas',
    'mould' => 'mold', 'plough' => 'plow', 'tyre' => 'tire', 'tyres' => 'tires', 'storey' => 'story'
  }.freeze

  PATTERN = begin
    stem_parts = STEMS.reject { |_, v| v.nil? }.map do |brit, _|
      ends = brit.end_with?('our') ? OUR_ENDS : IZE_ENDS
      "#{brit}(?:#{ends.reject(&:empty?).join('|')})#{'?' if ends.include?('')}"
    end
    Regexp.new("\\b(#{(stem_parts + WORDS.keys.map { |w| Regexp.escape(w) }).join('|')})\\b", Regexp::IGNORECASE)
  end

  module_function

  def american(word)
    lower = word.downcase
    out = WORDS[lower]
    unless out
      brit, us = STEMS.reject { |_, v| v.nil? }.max_by { |b, _| lower.start_with?(b) ? b.length : -1 }
      return word unless lower.start_with?(brit)

      out = us + lower[brit.length..]
    end
    return out.upcase if word == word.upcase && word.length > 1
    return out.capitalize if word[0] == word[0].upcase

    out
  end

  # Changes visible text only: never inside <tags>, links, email addresses or %{placeholders}
  def convert(text)
    return text if text.blank?

    text.to_s.split(/(<[^>]*>|%\{[^}]*\}|\S+@\S+|https?:\/\/\S+)/).map.with_index do |part, i|
      i.odd? ? part : part.gsub(PATTERN) { |w| american(w) }
    end.join
  end
end
