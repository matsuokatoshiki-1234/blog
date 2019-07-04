require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user1 = users(:user_one)
    @user2 = users(:user_two)
    @extension = ['.jpeg', '.png', '.gif', '.jpeg']
    unless Dir.exist?(Rails.root.to_s + '/test/fixtures/files/uploads/image/')
      FileUtils.mkdir Rails.root.to_s + '/test/fixtures/files/uploads/image/'
    end
    unless Dir.exist?(Rails.root.to_s + '/test/fixtures/files/uploads/tmp/')
      FileUtils.mkdir Rails.root.to_s + '/test/fixtures/files/uploads/tmp/'
    end
  end

  test 'indexアクションは正常に動作しているか' do
    login_as(@user1)
    get posts_path
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/index', 'テンプレートが正しくない')
    @posts = assigns(:posts)
    assert(is_descending_order(@posts), '降順ではない')
    @correct_post = @user1.posts.order(created_at: 'DESC').limit(10).offset(0)
    assert_equal(@correct_post, @posts, '@postsが正しくない')
    get posts_path, params: { page: 2 }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/index', 'テンプレートが正しくない')
    @posts = assigns(:posts)
    @correct_post = @user1.posts.order(created_at: 'DESC').limit(10).offset(10)
    assert_equal(@correct_post, @posts, '@postsが正しくない')
  end

  test 'indexアクションはログインなしの場合、リダイレクトされるか' do
    get posts_path
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

  test 'showアクションは正常に動作しているか' do
    @post_user1 = @user1.posts.sample
    @post_user2 = @user2.posts.sample
    login_as(@user1)
    get post_path(id: @post_user1)
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/show', 'テンプレートが正しくない')
    @post1 = assigns(:post1)
    @post2 = assigns(:post2)
    assert_equal(@post_user1, @post1, '@post1が正しくない')
    assert_equal(@post_user1, @post2, '@post2が正しくない')
    # 違うuserの記事の場合、リダイレクトされる
    get post_path(id: @post_user2)
    assert_response(:redirect, 'responseが正しくない')
    assert_equal('他のユーザーの記事は取得できません。', flash[:danger], 'flashが正しくない')
  end

  test 'showアクションは記事がない場合は404になるか' do
    login_as(@user1)
    get post_path(id: 100)
    assert_response(:missing, 'responseが正しくない')
    assert_template('errors/404', 'テンプレートが正しくない')
  end

  test 'showアクションはログインなしの場合、リダイレクトされるか' do
    get post_path(id: 1)
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

  test 'newアクションは正常に動作しているか' do
    login_as(@user1)
    get new_post_path
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/new', 'テンプレートが正しくない')
  end

  test 'newアクションはログインなしの場合、リダイレクトされるか' do
    get new_post_path
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

  test 'createアクションは正常に動作しているか' do
    login_as(@user1)
    @img = fixture_file_upload('/files/test/test_image_1.png', 'image/png')
    post posts_path, params: { post: { title: '記事のタイトルです。', body: '記事の内容です。', image: @img } }
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(posts_path, 'リダイレクト先が正しくない')
    assert_equal('記事の作成に成功しました。', flash[:success], 'flashが正しくない')
    # titleがない場合、失敗するか
    @img = fixture_file_upload('/files/test/test_image_1.png', 'image/png')
    post posts_path, params: { post: { title: '', body: '記事の内容です。', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/new', 'テンプレートが正しくない')
    assert_equal('記事の作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('タイトルを入力してください', @post.errors.full_messages[0], 'errorが正しくない')
    # titleが100文字より大きい場合、失敗するか
    @img = fixture_file_upload('/files/test/test_image_1.png', 'image/png')
    @title_text = create_text(101)
    assert_not(@title_text.size <= 100, '文字数が正しくない')
    post posts_path, params: { post: { title: @title_text, body: '記事の内容です。', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/new', 'テンプレートが正しくない')
    assert_equal('記事の作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('タイトルは100文字以内で入力してください', @post.errors.full_messages[0], 'errorが正しくない')
    # bodyがない場合、失敗するか
    @img = fixture_file_upload('/files/test/test_image_1.png', 'image/png')
    post posts_path, params: { post: { title: '記事のタイトルです。', body: '', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/new', 'テンプレートが正しくない')
    assert_equal('記事の作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('内容を入力してください', @post.errors.full_messages[0], 'errorが正しくない')
    # bodyが500文字より大きい場合、失敗するか
    @img = fixture_file_upload('/files/test/test_image_1.png', 'image/png')
    @body_text = create_text(501)
    assert_not(@body_text.size <= 500, '文字数が正しくない')
    post posts_path, params: { post: { title: '記事のタイトルです。', body: @body_text, image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/new', 'テンプレートが正しくない')
    assert_equal('記事の作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('内容は500文字以内で入力してください', @post.errors.full_messages[0], 'errorが正しくない')
    # imageがない場合、失敗するか
    post posts_path, params: { post: { title: '記事のタイトルです。', body: '記事の内容です。', image: '' } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/new', 'テンプレートが正しくない')
    assert_equal('記事の作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('画像を入力してください', @post.errors.full_messages[0], 'errorが正しくない')
    # imageが1byte~5megabytesではない場合、失敗するか
    @img = fixture_file_upload('/files/test/big_file_size.png', 'image/png')
    assert_not(File.size(@img).between?(1, 5_000_000), 'fileのsizeが正しくない')
    post posts_path, params: { post: { title: '記事のタイトルです。', body: '記事の内容です。', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/new', 'テンプレートが正しくない')
    assert_equal('記事の作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('画像のサイズは1~5MBまででお願いします。', @post.errors.full_messages[0], 'errorが正しくない')
    # imageがjpg,png,gif,jpeg以外だった場合、失敗するか
    @img = fixture_file_upload('/files/test/svg_file.svg', 'image/svg')
    assert_not(@extension.include?(File.extname(@img)), 'fileが正しくない')
    post posts_path, params: { post: { title: '記事のタイトルです。', body: '記事の内容です。', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/new', 'テンプレートが正しくない')
    assert_equal('記事の作成に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('画像の種類はpng,jpeg,jpg,gifでお願いします。', @post.errors.full_messages[0], 'errorが正しくない')
  end

  test 'createアクションはログインなしの場合、リダイレクトされるか' do
    @img = fixture_file_upload('/files/test/test_image_1.png', 'image/png')
    post posts_path, params: { post: { title: '記事のタイトルです。', body: '記事の内容です。', image: @img } }
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

  test 'editアクションは正常に動作しているか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    get edit_post_path(id: @post_user1)
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/edit', 'テンプレートが正しくない')
    @post = assigns(:post)
    assert_equal(@post_user1, @post, '@postが正しくない')
    # 違うuserの記事の場合、リダイレクトされる
    @post_user2 = @user2.posts.sample
    get edit_post_path(id: @post_user2)
    assert_response(:redirect, 'responseが正しくない')
    assert_equal('他のユーザーの記事を更新することはできません。', flash[:danger], 'flashが正しくない')
  end

  test 'editアクションは記事がない場合は404になるか' do
    login_as(@user1)
    get edit_post_path(id: 100)
    assert_response(:missing, 'responseが正しくない')
    assert_template('errors/404', 'テンプレートが正しくない')
  end

  test 'editアクションはログインなしの場合、リダイレクトされるか' do
    @post_user1 = @user1.posts.sample
    get edit_post_path(id: @post_user1)
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

  test 'updateアクションは正常に動作しているか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    @img = fixture_file_upload('/files/test/test_image_2.png', 'image/png')
    patch post_path(id: @post_user1), params: { post: { title: '更新されたタイトルです。', body: '更新された内容です。', image: @img } }
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(posts_path, 'リダイレクト先が正しくない')
    assert_equal('記事の更新に成功しました。', flash[:success], 'flashが正しくない')
    updated_post = Post.find(@post_user1.id)
    assert_not_equal(@post_user1.title, updated_post.title, '更新されていない')
    assert_not_equal(@post_user1.body, updated_post.body, '更新されていない')
    assert_not_equal(@post_user1.image.url, updated_post.image.url, '更新されていない')
    # 違うuserの記事の場合、リダイレクトされる
    @post_user2 = @user2.posts.sample
    patch post_path(id: @post_user2), params: { post: { title: '更新されたタイトルです。', body: '更新された内容です。', image: @img } }
    assert_response(:redirect, 'responseが正しくない')
    assert_equal('他のユーザーの記事を更新することはできません。', flash[:danger], 'flashが正しくない')
  end

  test 'updateアクションは記事がない場合は404になるか' do
    login_as(@user1)
    @img = fixture_file_upload('/files/test/test_image_2.png', 'image/png')
    patch post_path(id: 100), params: { post: { title: '更新されたタイトルです。', body: '更新された内容です。', image: @img } }
    assert_response(:missing, 'responseが正しくない')
    assert_template('errors/404', 'テンプレートが正しくない')
  end

  test 'updateアクションはtitleがない場合、失敗するか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    @img = fixture_file_upload('/files/test/test_image_2.png', 'image/png')
    patch post_path(id: @post_user1), params: { post: { title: '', body: '更新された内容です。', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/edit', 'テンプレートが正しくない')
    assert_equal('記事の更新に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('タイトルを入力してください', @post.errors.full_messages[0], 'errorが正しくない')
  end

  test 'updateアクションはtitleが100文字より多い場合、失敗するか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    @img = fixture_file_upload('/files/test/test_image_2.png', 'image/png')
    @title_text = create_text(101)
    assert_not(@title_text.size <= 100, '文字数が正しくない')
    patch post_path(id: @post_user1), params: { post: { title: @title_text, body: '更新された内容です。', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/edit', 'テンプレートが正しくない')
    assert_equal('記事の更新に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('タイトルは100文字以内で入力してください', @post.errors.full_messages[0], 'errorが正しくない')
  end

  test 'updateアクションはbodyがない場合、失敗するか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    @img = fixture_file_upload('/files/test/test_image_2.png', 'image/png')
    patch post_path(id: @post_user1), params: { post: { title: '更新されたタイトルです。', body: '', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/edit', 'テンプレートが正しくない')
    assert_equal('記事の更新に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('内容を入力してください', @post.errors.full_messages[0], 'errorが正しくない')
  end

  test 'updateアクションはbodyが500文字より多い場合、失敗するか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    @img = fixture_file_upload('/files/test/test_image_2.png', 'image/png')
    @body_text = create_text(501)
    assert_not(@body_text.size <= 100, '文字数が正しくない')
    patch post_path(id: @post_user1), params: { post: { title: '更新されたタイトルです。', body: @body_text, image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/edit', 'テンプレートが正しくない')
    assert_equal('記事の更新に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('内容は500文字以内で入力してください', @post.errors.full_messages[0], 'errorが正しくない')
  end

  test 'updateアクションはimageがない場合、失敗するか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    patch post_path(id: @post_user1), params: { post: { title: '更新されたタイトルです。', body: '更新された内容です。', image: '' } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/edit', 'テンプレートが正しくない')
    assert_equal('記事の更新に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('画像を入力してください', @post.errors.full_messages[0], 'errorが正しくない')
  end

  test 'updateアクションはimageが1byte~5megabytesではない場合、失敗するか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    @img = fixture_file_upload('/files/test/big_file_size.png', 'image/png')
    assert_not(File.size(@img).between?(1, 5_000_000), 'fileのsizeが正しくない')
    patch post_path(id: @post_user1), params: { post: { title: '更新されたタイトルです。', body: '更新された内容です。', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/edit', 'テンプレートが正しくない')
    assert_equal('記事の更新に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('画像のサイズは1~5MBまででお願いします。', @post.errors.full_messages[0], 'errorが正しくない')
  end

  test 'updateアクションはimageがjpg,png,gif,jpeg以外だった場合、失敗するか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    @img = fixture_file_upload('/files/test/svg_file.svg', 'image/svg')
    assert_not(@extension.include?(File.extname(@img)), 'fileが正しくない')
    patch post_path(id: @post_user1), params: { post: { title: '更新されたタイトルです。', body: '更新された内容です。', image: @img } }
    assert_response(:success, 'responseが正しくない')
    assert_template('posts/edit', 'テンプレートが正しくない')
    assert_equal('記事の更新に失敗しました。', flash[:danger], 'flashが正しくない')
    @post = assigns(:post)
    assert_equal('画像の種類はpng,jpeg,jpg,gifでお願いします。', @post.errors.full_messages[0], 'errorが正しくない')
  end

  test 'updateアクションはログインなしの場合、リダイレクトされるか' do
    @post_user1 = @user1.posts.sample
    @img = fixture_file_upload('/files/test/test_image_2.png', 'image/png')
    patch post_path(id: @post_user1), params: { post: { title: '記事のタイトルです。', body: '記事の内容です。', image: @img } }
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

  test 'destroyアクションは正常に動作しているか' do
    @post_user1 = @user1.posts.sample
    login_as(@user1)
    assert_difference('Post.count', -1, '削除されていない') do
      assert_difference('Comment.count', -1, '削除されていない') do
        delete post_path(id: @post_user1)
      end
    end
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(posts_path, 'リダイレクト先が正しくない')
    assert_equal('記事の削除に成功しました。', flash[:success], 'flashが正しくない')
    # 違うuserの記事の場合、リダイレクトされる
    @post_user2 = @user2.posts.sample
    delete post_path(id: @post_user2)
    assert_response(:redirect, 'responseが正しくない')
    assert_equal('他のユーザーの記事を削除することはできません。', flash[:danger], 'flashが正しくない')
  end

  test 'destroyアクションは記事がない場合は404になるか' do
    login_as(@user1)
    delete post_path(id: 100)
    assert_response(:missing, 'responseが正しくない')
    assert_template('errors/404', 'テンプレートが正しくない')
  end

  test 'destroyアクションはログインなしの場合、リダイレクトされるか' do
    @post_user1 = @user1.posts.sample
    delete post_path(id: @post_user1)
    assert_response(:redirect, 'responseが正しくない')
    assert_redirected_to(new_user_session_path, 'リダイレクト先が正しくない')
  end

  teardown do
    if Dir.exist?(Rails.root.to_s + '/test/fixtures/files/uploads/image/')
      FileUtils.remove_entry Rails.root.to_s + '/test/fixtures/files/uploads/image/'
    end
    if Dir.exist?(Rails.root.to_s + '/test/fixtures/files/uploads/tmp/')
      FileUtils.remove_entry Rails.root.to_s + '/test/fixtures/files/uploads/tmp/'
    end
  end

end
