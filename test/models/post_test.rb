require 'test_helper'

class PostTest < ActiveSupport::TestCase

  setup do
    @user = users(:user_one)
    @extension = ['.jpeg', '.png', '.gif', '.jpeg']
    @file_name = 'test_image_1.png'
    @big_size_file_name = 'big_file_size.png'
    @svg_file_name = 'svg_file.svg'
    unless Dir.exist?(Rails.root.to_s + '/test/fixtures/files/uploads/image/')
      FileUtils.mkdir Rails.root.to_s + '/test/fixtures/files/uploads/image/'
    end
    unless Dir.exist?(Rails.root.to_s + '/test/fixtures/files/uploads/tmp/')
      FileUtils.mkdir Rails.root.to_s + '/test/fixtures/files/uploads/tmp/'
    end
  end

  test '保存に成功するか' do
    @img = fixture_file_upload('/files/test/' + @file_name)
    @post = @user.posts.new(title: '記事のタイトルです。', body: '記事の内容です。', image: @img)
    assert(@post.save, '保存に失敗している')
  end

  test 'userがない場合、失敗するか' do
    @img = fixture_file_upload('/files/test/' + @file_name)
    @post = Post.new(title: '記事のタイトルです。', body: '記事の内容です。', image: @img)
    assert_not(@post.save, '保存に成功している')
  end

  test 'titleがない場合、失敗するか' do
    @img = fixture_file_upload('/files/test/' + @file_name)
    @post = @user.posts.new(title: '', body: '記事の内容です。', image: @img)
    assert_not(@post.save, '保存に成功している')
    assert_equal(@post.errors.full_messages[0], 'タイトルを入力してください', 'errorが正しくない')
  end

  test 'titleが100文字より大きい場合、失敗するか' do
    @title_text = create_text(101)
    assert_not(@title_text.size <= 100, 'titleが100文字より大きくない')
    @img = fixture_file_upload('/files/test/' + @file_name)
    @post = @user.posts.new(title: @title_text, body: '記事の内容です。', image: @img)
    assert_not(@post.save, '保存に成功している')
    assert_equal(@post.errors.full_messages[0], 'タイトルは100文字以内で入力してください', 'errorが正しくない')
  end

  test 'bodyがない場合、失敗するか' do
    @img = fixture_file_upload('/files/test/' + @file_name)
    @post = @user.posts.new(title: '記事のタイトルです。', body: '', image: @img)
    assert_not(@post.save, '保存に成功している')
    assert_equal(@post.errors.full_messages[0], '内容を入力してください', 'errorが正しくない')
  end

  test 'bodyが500文字より大きい場合、失敗するか' do
    @body_text = create_text(501)
    assert_not(@body_text.size <= 500, 'titleが500文字より大きくない')
    @img = fixture_file_upload('/files/test/' + @file_name)
    @post = @user.posts.new(title: '記事のタイトルです。', body: @body_text, image: @img)
    assert_not(@post.save, '保存に成功している')
    assert_equal(@post.errors.full_messages[0], '内容は500文字以内で入力してください', 'errorが正しくない')
  end

  test '保存された場合、指定されたディレクトリにアップロードされたかとアップロードされたファイル名が変更されているか' do
    @img = fixture_file_upload('/files/test/' + @file_name)
    @post = @user.posts.new(title: '記事のタイトルです。', body: '記事の内容です。', image: @img)
    @dir = @post.tap(&:save).image.to_s
    assert(File.exist?(@dir), 'ファイルが指定されたディレクトリに存在しない')
    @upload_file_name = File.basename(@dir)
    assert_not_equal(@file_name, @upload_file_name, 'アップロードされたファイルの名前が変更されていない')
  end

  test 'imageがない場合、失敗するか' do
    @post = @user.posts.new(title: '記事のタイトルです。', body: '記事の内容です。', image: '')
    assert_not(@post.save, '保存に成功している')
    assert_equal(@post.errors.full_messages[0], '画像を入力してください', 'errorが正しくない')
  end

  test 'imageが1byte~5megabytesではない時に失敗するか' do
    @img = fixture_file_upload('/files/test/' + @big_size_file_name)
    assert_not(File.size(@img).between?(1, 5_000_000), 'fileのsizeが1byte~5megabytesである')
    @post = @user.posts.new(title: '記事のタイトルです。', body: '記事の内容です。', image: @img)
    assert_not(@post.save, '保存に成功している')
    assert_equal(@post.errors.full_messages[0], '画像のサイズは1~5MBまででお願いします。', 'errorが正しくない')
  end

  test 'imageがjpg,png,gif,jpeg以外だった場合、失敗するか' do
    @img = fixture_file_upload('/files/test/' + @svg_file_name)
    assert_not(@extension.include?(File.extname(@img)), 'fileがjpg,png,gif,jpegのどれかに当てはまっている')
    @post = @user.posts.new(title: '記事のタイトルです。', body: '記事の内容です。', image: @img)
    assert_not(@post.save, '保存に成功している')
    assert_equal(@post.errors.full_messages[0], '画像の種類はpng,jpeg,jpg,gifでお願いします。', 'errorが正しくない')
  end

  test 'postを削除するとcommentの削除されるか' do
    assert_difference('Post.count', -1, 'postが削除されていない') do
      assert_difference('Comment.count', -1, 'commentが削除されていない') do
        posts(:post_one).destroy
      end
    end
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
