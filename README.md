# README

URL : [knowledge-free-blog.tk](https://knowledge-free-blog.tk/)

ruby 2.6.1  
Rails 5.2.3  
Docker 19.03.2  
docker-compose 1.24.1  

## 使用したGem
* devise
* carrierwave
* kaminari
* rails-i18n
* file_validators
* therubyracer
* rails-controller-testing

テスト用のアカウントです。  
メールアドレス : test.knowledge.free.blog.tk@gmail.com  
パスワード : tjuoomAU

## 機能
* ログイン
* 画像アップロード
* ページネーション
* 記事一覧
* 記事詳細
* 記事編集
* 記事削除

## Dockerでの起動方法  
```
git clone https://github.com/matsuokatoshiki-1234/blog.git
cd blog
docker-compose build
docker-compose run blog bin/rake db:create db:migrate
docker-compose up
```
localhost:3000でアクセスできます。
