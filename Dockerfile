FROM ruby:2.6.1

RUN apt-get update && apt-get install -y mysql-client

WORKDIR /blog

COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v 2.0.1

RUN bundle install