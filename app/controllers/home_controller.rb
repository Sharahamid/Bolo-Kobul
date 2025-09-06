class HomeController < ApplicationController
  before_action :authenticate_user!, 
  :check_current_active_profile, 
  :check_preference, except: [:landing, :about, :email_template, :contact, :animation]

  def landing
    @user = User.new
    @success_stories = Blog.approved.success_story
  end

  def about
    @about_content = About.all.order(:display_order)
  end

  def contact
    @contact = Contact.last
  end

  def email_template

  end

  def animation
  end

  def use_reference
    @user = current_user
  end
end
