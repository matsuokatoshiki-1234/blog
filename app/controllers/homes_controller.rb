class HomesController < ApplicationController

  def index
    @posts = Post.all.order(created_at: "DESC")
  end

  def show
    @post1 = Post.find(params[:id])
    @post2 = Post.find(params[:id])
  end

end
