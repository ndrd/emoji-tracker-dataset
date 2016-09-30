require 'tweetstream'
require 'uri'
require 'socket'

#convenience method for reading booleans from env vars
def to_boolean(s)
  s and !!s.match(/^(true|t|yes|y|1)$/i)
end

# verbose mode or no
VERBOSE = to_boolean(ENV["VERBOSE"]) || false

# profile mode or no
PROFILE = to_boolean(ENV["PROFILE"]) || false

# configure tweetstream instance
TweetStream.configure do |config|
  config.consumer_key       = ENV['CONSUMER_KEY']
  config.consumer_secret    = ENV['CONSUMER_SECRET']
  config.oauth_token        = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
  config.auth_method = :oauth
end

