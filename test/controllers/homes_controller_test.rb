require 'test_helper'

class HomesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user1 = users(:user_one)
    @user2 = users(:user_two)
  end
  
  test 'indexアクションは正常に動作しているか' do
    get root_path
    assert_response(:success, 'responseが正しくない')
    assert_template('homes/index', 'テンプレートが正しくない')
    @posts = assigns(:posts)
    assert(is_descending_order(@posts), '降順ではない')
    @correct_posts = Post.all.order(created_at: 'DESC').limit(10).offset(0)
    assert_equal(@correct_posts, @posts, '@postsが正しくない')
    get root_path, params: { page: 2 }
    assert_response(:success, 'responseが正しくない')
    assert_template('homes/index', 'テンプレートが正しくない')
    @posts = assigns(:posts)
    @correct_posts = Post.all.order(created_at: 'DESC').limit(10).offset(10)
    assert_equal(@correct_posts, @posts, '@postsが正しくない')
  end

  test 'showアクションは正常に動作しているか' do
    sample_post = Post.all.sample
    get home_path(sample_post)
    assert_response(:success, 'responseが正しくない')
    assert_template('homes/show', 'テンプレートが正しくない')
    @post1 = assigns(:post1)
    @post2 = assigns(:post2)
    assert_equal(sample_post, @post1, '@post1が正しくない')
    assert_equal(sample_post, @post2, '@post2が正しくない')
    #記事がない場合は404になるか
    get home_path(100)
    assert_response(:missing, 'responseが正しくない')
    assert_template('errors/404', 'テンプレートが正しくない')
  end

end
