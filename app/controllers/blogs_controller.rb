class BlogsController < ApplicationController
  def index
    @blogs = Blog.approved.order(created_at: :desc)
    @blogs = @blogs.where(story_type: params[:type]) if params[:type].present?
    @blogs = @blogs.paginate(page: params[:page], per_page: 10)
    @blog = Blog.new
  end

  def show
    @blog = Blog.friendly.find(params[:id])
    # An old link by number (/blogs/12) moves to the story's named address
    redirect_to blog_path(@blog.slug, locale: params[:locale].presence), status: :moved_permanently if @blog.slug.present? && params[:id] != @blog.slug
  end

  def create
    @blog = Blog.create(blog_params)
    flash[:notice] = "Thanks for sharing your precious story with us!"
    AdminSupportMailer.with(blog: @blog).new_story.deliver_later
    redirect_to blogs_path
  rescue StandardError => exception
    flash[:error] = "Something went wrong! Detail: #{exception}"
    redirect_to fallback_location: blogs_path
  end

  private

  def blog_params
    params.require(:blog).permit(
      :author, :partner, :title, :email, :married_life_duration, :story,
      :image
    )
  end
end
