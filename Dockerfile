FROM ruby:2.6.4-buster

RUN apt-get update \
    && apt-get install -y default-mysql-client

WORKDIR /blog

COPY Gemfile Gemfile.lock ./

RUN gem install bundler -v 2.0.1 \
    && bundle install