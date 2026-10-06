class AddDisplayOrderToMarketPlaceTypes < ActiveRecord::Migration[8.1]
  FIRST = ['honeymoon', 'makeover', 'wedding attire'].freeze

  def up
    add_column :market_place_types, :display_order, :integer, default: 100, null: false

    # Honeymoon, Makeover and Wedding Attire first; the rest keep their current order after them
    rows = select_rows('SELECT id, name FROM market_place_types ORDER BY id')
    rows.each_with_index do |(id, name), index|
      key = name.to_s.tr('_', ' ').squish.downcase
      position = FIRST.index(key)
      order = position ? position + 1 : 10 + index
      execute "UPDATE market_place_types SET display_order = #{order.to_i} WHERE id = #{id.to_i}"
    end
  end

  def down
    remove_column :market_place_types, :display_order
  end
end
