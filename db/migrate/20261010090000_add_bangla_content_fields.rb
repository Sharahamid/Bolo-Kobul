# Bangla versions of the text the admin writes (About, Contact, FAQ, safety tips,
# privacy policy, terms, how it works). Empty means the English text is shown.
class AddBanglaContentFields < ActiveRecord::Migration[8.1]
  FIELDS = {
    abouts: { content_type_bn: :string, content_bn: :text },
    contacts: { heading_bn: :string, content_bn: :text },
    faqs: { title_bn: :string, content_bn: :text },
    precautionary_measures: { title_bn: :string, content_bn: :text },
    privacy_policies: { title_bn: :string, content_bn: :text },
    terms_of_uses: { title_bn: :string, content_bn: :text },
    process_flows: { title_bn: :string }
  }.freeze

  def change
    FIELDS.each do |table, columns|
      columns.each { |column, type| add_column table, column, type }
    end
  end
end
