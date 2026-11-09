class BlogsController < ApplicationController
  def index
    @blogs = Blog.approved.order(created_at: :desc)
    @blogs = @blogs.where(story_type: params[:type]) if params[:type].present?
    @blogs = @blogs.paginate(page: params[:page], per_page: 10)
    @blog = Blog.new
  end

  def show
    @blog = Blog.friendly.find(params[:id]) rescue nil
    return if @blog

    # A cut-off link (e.g. /blogs/taurus or /blogs/aries-) goes to the article whose
    # address starts with it; anything else goes to the blog list. Both are permanent
    # redirects, so Google updates its records instead of reporting "Not found".
    fragment = params[:id].to_s.downcase.strip.sub(/-+\z/, '')
    match = Blog.where('slug LIKE ?', "#{Blog.sanitize_sql_like(fragment)}%").order(:id).first if fragment.length >= 3
    return redirect_to(blog_path(match), status: :moved_permanently) if match

    redirect_to blogs_path, notice: t('bkx.gone.article'), status: :moved_permanently
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
