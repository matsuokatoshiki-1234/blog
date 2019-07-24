require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  setup do
    @user = users(:user_one)
    @post = posts(:post_one)
  end

  test "保存に成功するか" do
    @comment = @post.comments.new(body: 'コメントです。')
    @comment.user = @user
    assert(@comment.save, '保存に失敗している。')
  end

  test "userがない場合、保存に失敗するか" do
    @comment = @post.comments.new(body: 'コメントです。')
    assert_not(@comment.save, '保存に成功している。')
  end

  test "postがない場合、保存に失敗するか" do 
    @comment = Comment.new(body: 'コメントです。')
    @comment.user = @user
    assert_not(@comment.save, '保存に成功している。')
  end

  test "commentがない場合、保存に失敗するか" do  
    @comment = @post.comments.new(body: '')
    @comment.user = @user
    assert_not(@comment.save, '保存に成功している。')
    assert_equal(@comment.errors.full_messages[0], 'コメントを入力してください' ,'errorが正しくない')
  end

  test "commentが200文字より大きい場合、保存に失敗するか" do
    @comment_text = create_text(201)
    assert_not(200 >= @comment_text.size, 'commentが200文字より大きくない')
    @comment = @post.comments.new(body: @comment_text)
    @comment.user = @user
    assert_not(@comment.save, '保存に成功している。')
    assert_equal(@comment.errors.full_messages[0], 'コメントは200文字以内で入力してください' ,'errorが正しくない')
  end

  test "commentが10件以上だった場合、保存に失敗するか" do
    @post = posts(:post_14)
    assert_not(10 > @post.comments.count, 'commentが10件以上ではない')
    @comment = @post.comments.new(body: 'コメントです。')
    @comment.user = @user
    assert_not(@comment.save, '保存に成功している。')
    assert_equal(@comment.errors.full_messages[0], 'コメント数の上限に達したのでコメントできませんでした。' ,'errorが正しくない')
  end

end
