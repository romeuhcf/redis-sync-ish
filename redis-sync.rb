#!/usr/bin/env ruby
# frozen_string_literal: true

# This script is used to sync data from one redis to another redis
# It uses SCAN to iterate over keys and then GET to get the value
# It uses a pattern to filter the keys to be moved

require 'bundler/setup'

require 'redis'
require 'colorize'

def usage
  puts "#{$PROGRAM_NAME} (once | loop) <source_redis_url> <destination_redis_url> <pattern1> <pattern2> ..."
end

def debug(*args)
  puts(*args) if ENV['DEBUG']
end



def sync_loop(mode, source_redis_url, destination_redis_url, pattern)
  source_redis = Redis.new(url: source_redis_url)
  destination_redis = Redis.new(url: destination_redis_url)
  migrated = {}
  loop_count = 0

  loop do
    color = loop_count.zero? ? :yellow : :green
    migrated_size_was = migrated.size
    cursor = '0'
    skipped_count = 0
    loop do
      cursor, keys = source_redis.scan(cursor, count: 1000, match: pattern)
      debug "#{pattern}: Cursor: #{cursor}".send(color)
      keys.each do |key|
        type = source_redis.type(key)
        next unless type == 'string'

        value = source_redis.get(key)
        if migrated[key]
          debug "#{pattern}: Skipped #{key}".send(color)
          skipped_count += 1
          next
        end

        ttl = source_redis.ttl(key)
        destination_redis.set(key, value)

        destination_redis.expire(key, ttl) if ttl.positive?
        migrated[key] = true

        puts "#{pattern}: Copied key: #{key} ".send(color)
      end
      break if cursor == '0'
    end
    break if mode == 'once'

    loop_migration_counter = migrated.size - migrated_size_was
    loop_count += 1
    puts "#{pattern}: looped -> migrated #{loop_migration_counter} skipped: #{skipped_count}".send(color)
    sleep 0.1
  end
end

if ARGV.size < 4
  usage
  exit 1
end

mode = ARGV[0]
ARGV.shift

source_redis_url = ARGV[0]
destination_redis_url = ARGV[1]
patterns = ARGV[2..]

threads = patterns.map do |pattern|
  Thread.new do
    sync_loop(mode, source_redis_url, destination_redis_url, pattern)
  end
end

threads.each(&:join)
