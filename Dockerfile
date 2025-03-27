FROM ruby:3-alpine

RUN apk add vim bash redis

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install -j $(nproc)

COPY redis-sync.rb .

