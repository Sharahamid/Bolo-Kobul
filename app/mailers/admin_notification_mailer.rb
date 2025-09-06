class AdminNotificationMailer < ApplicationMailer
  def new_story
    @blog = params[:blog]
    mail(to: ENV['ADMIN_EMAIL'],
         subject: "New story submitted at Bolo Kobul")
  end
end
