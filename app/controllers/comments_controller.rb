class CommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create    
    @post1 = Post.find(params[:post_id])
    @post2 = Post.find(params[:post_id])
    @post = Post.find(params[:post_id])
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to home_path(@post) 
    else   
      render 'homes/show' 
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post)
  end

  private
    def comment_params
      params.require(:comment).permit(:body)
    end

end
