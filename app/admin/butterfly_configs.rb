ActiveAdmin.register ButterflyConfig, as: "Configurations" do
  menu parent: 'Manage Site'
  permit_params :butterfly_price, :profile_view_butterflies, :chat_butterflies,
                :text_alert_butterflies, :num_of_free_butterfly,
                :butterfly_animation, :adv_search_butterflies,
                :max_marriage_profiles
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
      input :butterfly_animation, as: :select,
            label: "Butterfly Animation"
    end
    f.actions
  end
end
