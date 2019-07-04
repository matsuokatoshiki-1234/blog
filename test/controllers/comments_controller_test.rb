require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user1 = users(:user_one)
    @user2 = users(:user_two)
  end

  test 'createアクションは正常に動作しているか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    post post_comments_path(@post_user1), params: { comment: { body: 'コメントです。' } }
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(home_path(@post_user1), 'リダイレクト先が正しくない')
    assert_equal('コメントの作成に成功しました。', flash[:success], 'flashが正しくない')
    # bodyがない場合、失敗するか
    post post_comments_path(@post_user1), params: { comment: { body: '' } }
    assert_response(:success, 'responseが正しくない')
    assert_template('homes/show', 'テンプレートが正しくない')
    assert_equal('コメントの作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @comment = assigns(:comment)
    assert_equal('コメントを入力してください', @comment.errors.full_messages[0], 'errorが正しくない')
    # bodyが200文字より大きい場合、失敗するか
    @comment_text = create_text(201)
    assert_not(@comment_text.size <= 200, '文字数が正しくない')
    post post_comments_path(@post_user1), params: { comment: { body: @comment_text } }
    assert_response(:success, 'responseが正しくない')
    assert_template('homes/show', 'テンプレートが正しくない')
    assert_equal('コメントの作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @comment = assigns(:comment)
    assert_equal('コメントは200文字以内で入力してください', @comment.errors.full_messages[0], 'errorが正しくない')
  end

  test 'createアクションは記事がない場合は404になるか' do
    login_as(@user1)
    post post_comments_path(post_id: 100), params: { comment: { body: 'コメントです。' } }
    assert_response(:missing, 'responseが正しくない')
    assert_template('errors/404', 'テンプレートが正しくない')
  end

  test 'createアクションはログインなしの場合、リダイレクトされるか' do
    @post_user1 = @user1.posts.sample
    post post_comments_path(@post_user1), params: { comment: { body: 'コメントです。' } }
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

  test 'destroyアクションは正常に動作しているか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    assert_difference('Comment.count', -1, '削除されていない') do
      delete post_comment_path(post_id: @post_user1.id, id: @post_user1.comments.sample.id)
    end
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(post_path(@post_user1), 'リダイレクト先が正しくない')
    assert_equal('コメントの削除に成功しました。', flash[:success], 'flashが正しくない')
    # 違うuserの記事の場合、リダイレクトされる
    @post_user2 = @user2.posts.sample
    delete post_comment_path(post_id: @post_user2.id, id: @post_user2.comments.sample.id)
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(posts_path, 'リダイレクト先が正しくない')
    assert_equal('他のユーザーの記事のコメントを削除することはできません。', flash[:danger], 'flashが正しくない')
  end

  test 'destroyアクションは記事がない場合は404になるか' do
    login_as(@user1)
    @post_user1 = @user1.posts.sample
    delete post_comment_path(post_id: 100, id: @post_user1.comments.sample.id)
    assert_response(:missing, 'responseが正しくない')
    assert_template('errors/404', 'テンプレートが正しくない')
  end

  test 'destroyアクションはコメントがない場合は404になるか' do
    login_as(@user1)
    @post_user1 = @user1.posts.sample
    delete post_comment_path(post_id: @post_user1.id, id: 100)
    assert_response(:missing, 'responseが正しくない')
    assert_template('errors/404', 'テンプレートが正しくない')
  end

  test 'destroyアクションはログインなしの場合、リダイレクトされるか' do
    @post_user1 = @user1.posts.sample
    delete post_comment_path(post_id: @post_user1.id, id: @post_user1.comments.sample.id)
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

end
