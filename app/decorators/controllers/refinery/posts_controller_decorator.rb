Refinery::Blog::PostsController.class_eval do
  layout 'website'

  skip_authorization_check

  def author
    @posts_author = User.find(params[:author_id])
    @posts = Refinery::Blog::Post.where(author: @posts_author).page(params[:page])
    respond_with (@posts) do |format|
          format.html
          format.rss { render :layout => false }
    end
  end

  protected
end