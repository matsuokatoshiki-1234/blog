class HomesController < ApplicationController

  def index
    @posts = Post.all.order(created_at: "DESC").page(params[:page]).per(10)
  end

  def show
    @post1 = Post.find(params[:id])
    @post2 = Post.find(params[:id])
    @comment = Comment.new
  end

end
