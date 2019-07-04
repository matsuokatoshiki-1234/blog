class CommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create    
    @post1 = Post.find_by(id: params[:post_id])
    @post2 = Post.find_by(id: params[:post_id])
    @post = Post.find_by(id: params[:post_id])
    if @post1 === nil || @post2 === nil || @post === nil
      return render 'errors/404', status: 404
    end
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user
    if @comment.save
      flash[:success] = "コメントの作成に成功しました。"
      redirect_to home_path(@post) 
    else   
      flash[:danger] = "コメントの作成に失敗しました。"
      render 'homes/show' 
    end
  end

  def destroy
    @post = Post.find_by(id: params[:post_id])
    if @post === nil
      return render 'errors/404', status: 404
    end
    @comment = @post.comments.find_by(id: params[:id])
    if @comment === nil
      return render 'errors/404', status: 404
    end
    if current_user.id == @post.user_id
      if @comment.destroy
        flash[:success] = "コメントの削除に成功しました。"
        redirect_to post_path(@post)
      else
        flash[:danger] = "コメントの削除に失敗しました。"
        redirect_to posts_path(@post)
      end
    else
      flash[:danger] = "他のユーザーの記事のコメントを削除することはできません。"
      redirect_to posts_path
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:body)
    end

end
