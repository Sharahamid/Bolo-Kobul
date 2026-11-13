ActiveAdmin.register MessageSetting, as: "Messages On Off" do
  menu parent: 'Settings', priority: 4, label: 'Messages On / Off'
  config.filters = false
  permit_params :sms_all, :email_all, on_keys: []
  actions :index, :edit, :update

  controller do
    # There is only one row: the menu opens its edit page straight away
    def index
      redirect_to edit_resource_path(MessageSetting.current)
    end

    def update
      super do |success, _failure|
        success.html { redirect_to edit_resource_path(resource), notice: 'Saved. The new settings work straight away.' }
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs 'Master switches' do
      f.input :sms_all, label: 'ALL SMS', hint: 'When OFF, no text message is sent at all, whatever is ticked below.'
      f.input :email_all, label: 'ALL EMAILS', hint: 'When OFF, none of the emails below is sent. (Password-reset emails are always sent.)'
    end
    MessageSetting::CATALOG.group_by { |row| row[1] }.each do |section, rows|
      f.inputs "#{section} (ticked = sent)" do
        f.input :on_keys, as: :check_boxes, label: false,
                collection: rows.map { |key, _section, label| [label, key] }
      end
    end
    f.actions do
      f.action :submit, label: 'Save'
    end
  end
end
