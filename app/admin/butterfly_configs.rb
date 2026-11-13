ActiveAdmin.register ButterflyConfig, as: "Configurations" do
  menu parent: 'Settings', priority: 1, label: 'Butterfly prices'
  config.filters = false
  permit_params :butterfly_price, :profile_view_butterflies, :chat_butterflies,
                :text_alert_butterflies, :num_of_free_butterfly,
                :butterfly_animation, :adv_search_butterflies,
                :max_marriage_profiles, :kobul1_expiry_days,
                :anim_kobul1_recommendations, :anim_kobul1_request, :anim_kobul2
  actions :all, :except => [:new, :destroy]

  show do
    attributes_table do
      row "Butterflies Per Profile view request" do |butterfly_config|
        butterfly_config.profile_view_butterflies
      end
      row "Butterflies Per Chat request" do |butterfly_config|
        butterfly_config.chat_butterflies
      end
      row "Butterflies Per User's Text Alert" do |butterfly_config|
        butterfly_config.text_alert_butterflies
      end
      row "Butterflies Per User's Advanced Search" do |butterfly_config|
        butterfly_config.adv_search_butterflies
      end
      row "Butterflies Free Per 'self' user" do |butterfly_config|
        butterfly_config.num_of_free_butterfly
      end
      row "Price per butterfly" do |butterfly_config|
        butterfly_config.butterfly_price
      end
      row "Maximum Marriage Profiles" do |butterfly_config|
        butterfly_config.max_marriage_profiles
      end
      row "1st Kobul expires after (days)" do |butterfly_config|
        butterfly_config.kobul1_expiry_days
      end
      row "Butterfly Animation" do |butterfly_config|
        butterfly_config.butterfly_animation
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :profile_view_butterflies, as: :number,
            label: "Butterflies Per Profile view request"
      input :chat_butterflies, as: :number,
            label: "Butterflies Per Chat request"
      input :text_alert_butterflies, as: :number,
            label: "Price per User Text Alert"
      input :adv_search_butterflies, as: :number,
            label: "Price per User Advanced Search"
      input :num_of_free_butterfly, as: :number,
            label: "Butterflies Free Per 'self' user"
      input :butterfly_price, as: :number,
            label: "Price per butterfly"
      input :max_marriage_profiles, as: :number,
            label: "Maximum Marriage Profiles"
    end
    f.inputs 'Kobul expiry' do
      input :kobul1_expiry_days, as: :number, min: 1, max: 90,
            label: '1st Kobul expires after (days)',
            hint: 'An unanswered 1st Kobul closes after this many days and the sender gets the butterflies back. ' \
                  'The receiver is reminded 2 days before (only when this is 3 days or more). ' \
                  'A change applies to all waiting Kobuls, counted from the day each was sent. 2nd Kobuls never expire.'
    end
    f.inputs 'Butterfly animations' do
      input :butterfly_animation, label: 'Master: All Butterfly Animations', as: :boolean
      input :anim_kobul1_recommendations, label: 'Kobul 1 Click (Recommendations → Requests Sent)', as: :boolean
      input :anim_kobul1_request, label: 'Kobul 1 Click (1st Kobul Received → Chat Requests Sent)', as: :boolean
      input :anim_kobul2, label: 'Kobul 2 Click (2nd Kobul Received → Chats)', as: :boolean
    end
    f.actions
  end
end
