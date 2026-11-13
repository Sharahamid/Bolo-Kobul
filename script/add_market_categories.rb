# Adds the 13 new Wedding Shopping categories (Nov 2026). Safe to run more than once.
# Run on the server: RAILS_ENV=production bundle exec rails runner script/add_market_categories.rb
NAMES = [
  'Decorators and Stage',
  'Wedding Planners',
  'Mehendi Artists',
  'Kazi and Registration',
  'Invitation Cards',
  'Tattwa and Gifts',
  'Cakes and Sweets',
  'Florists',
  'Bridal Car and Transport',
  'Music DJ and Sound',
  'Lighting',
  'Tent and Furniture Rental',
  'Guest Stay',
].freeze

start = [MarketPlaceType.maximum(:display_order).to_i, 100].max
NAMES.each_with_index do |name, i|
  type = MarketPlaceType.find_or_initialize_by(name: name)
  if type.new_record?
    type.display_order = start + (i + 1) * 10
    type.save!
    puts "Added: #{name}"
  else
    puts "Already there: #{name}"
  end
end
puts "Categories now: #{MarketPlaceType.count}"
