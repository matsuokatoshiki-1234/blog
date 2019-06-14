class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @posts = User.find(current_user.id).posts.order(created_at: "DESC").page(params[:page]).per(10)
  end

  def show
    @post1 = Post.find(params[:id])
    @post2 = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = User.find(current_user.id).posts.new(post_params)
    if @post.save
      redirect_to posts_path 
    else
      render 'new'
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if current_user.id == @post.user_id
      if @post.update(post_params)
        redirect_to posts_path
      else
        render 'edit'
      end
    else
      redirect_to posts_path
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if current_user.id == @post.user_id
      @post.delete()
      redirect_to posts_path
    else
      redirect_to posts_path
    end
  end

  private
    def post_params
      params.require(:post).permit(:title, :body, :image)
    end

end
