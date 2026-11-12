ActiveAdmin.register MessageSetting, as: "Messages On Off" do
  menu parent: 'Manage Site', label: 'Messages On / Off'
  permit_params :sms_all, :sms_otp, :sms_kobul, :sms_purchase, :sms_text_alerts,
                :email_all, :email_account, :email_kobul, :email_chat, :email_purchase,
                :email_reminders, :email_admin
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
    f.inputs 'SMS (text messages)' do
      f.input :sms_all, label: 'ALL SMS', hint: 'Master switch. When OFF, no text message is sent at all.'
      f.input :sms_otp, label: 'Sign-up and login codes',
              hint: 'WARNING: if OFF, codes are sent by email instead. If login-code emails are also OFF, members cannot sign up or log in with their phone.'
      f.input :sms_kobul, label: 'Kobul updates', hint: '1st and 2nd Kobul sent, received, accepted, declined and expired.'
      f.input :sms_purchase, label: 'Purchase confirmations'
      f.input :sms_text_alerts, label: 'Text Alerts (members who paid butterflies for SMS alerts)',
              hint: 'If OFF, members who paid for Text Alerts will not get them.'
    end
    f.inputs 'Emails' do
      f.input :email_all, label: 'ALL EMAILS', hint: 'Master switch. When OFF, none of the emails below is sent. (Password-reset emails are always sent.)'
      f.input :email_account, label: 'Account emails: welcome, login codes, account deletion',
              hint: 'WARNING: if OFF together with login-code SMS, members cannot sign up or log in.'
      f.input :email_kobul, label: 'Kobul emails', hint: 'Sent, received, accepted, declined and expired.'
      f.input :email_chat, label: 'New chat message emails'
      f.input :email_purchase, label: 'Purchase and notification emails'
      f.input :email_reminders, label: 'Weekly reminder and matches emails'
      f.input :email_admin, label: 'Emails to the Bolo Kobul team',
              hint: 'New tickets, payments, reports, new admin logins, low SMS balance, twice-monthly report.'
    end
    f.actions do
      f.action :submit, label: 'Save'
    end
  end
end
