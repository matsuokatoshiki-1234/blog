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
      flash[:success] = "記事の作成に成功しました。"
      redirect_to posts_path 
    else
      flash[:danger] = "記事の作成に失敗しました。"
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
        flash[:success] = "記事の更新に成功しました。"
        redirect_to posts_path
      else
        flash[:danger] = "記事の更新に失敗しました。"
        render 'edit'
      end
    else
      flash[:danger] = "他のユーザーの記事を更新することはできません。"
      redirect_to posts_path
    end
  end

  def destroy
    @post = Post.find(params[:id])
    if current_user.id == @post.user_id
      if @post.destroy
        flash[:success] = "記事の削除に成功しました。"
        redirect_to posts_path
      else
        flash[:danger] = "記事の削除に失敗しました。"
        redirect_to posts_path
      end
    else
      flash[:danger] = "他のユーザーの記事を削除することはできません。"
      redirect_to posts_path
    end
  end

  private
    def post_params
      params.require(:post).permit(:title, :body, :image, :image_cache)
    end

end
