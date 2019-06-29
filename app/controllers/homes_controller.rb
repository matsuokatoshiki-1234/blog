class HomesController < ApplicationController

  def index
    @posts = Post.all.order(created_at: "DESC").page(params[:page]).per(10)
  end

  def show
    @post1 = Post.find_by(id: params[:id])
    @post2 = Post.find_by(id: params[:id])
    if @post1 === nil || @post2 === nil
      return render 'errors/404', status: 404
    end
    @comment = Comment.new
  end
end
