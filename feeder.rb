#!/usr/bin/env ruby
require_relative 'lib/config'
require 'emoji_data'
require 'oj'
require 'colored'
require 'eventmachine'
require 'emoji_data'

TERMS = ['el','la','de','que','y','a','en','un','ser','se','no','haber','por','con','su','para','como','estar','tener','le','lo','lo','todo','pero','mas','hacer','o','poder','decir','este','ir','otro','ese','la','si','me','ya','ver','porque','dar','cuando','el','muy','sin','vez','mucho','saber','que','sobre','mi','alguno','mismo','yo','tambien','hasta','año','dos','querer','entre','asi','primero','desde','grande','eso','ni','nos','llegar','pasar','tiempo','ella','si','dia','uno','bien','poco','deber','entonces','poner','cosa','tanto','hombre','parecer','nuestro','tan','donde','ahora','parte','despues','vida','quedar','siempre','creer','hablar','llevar','dejar','nada','cada','seguir','menos','nuevo']

 # initialize streaming counts
  puts "Setting up a stream to track #{TERMS.size} terms '#{TERMS}'..."
  @tracked,@skipped,@tracked_last,@skipped_last = 0,0,0,0
  @client = TweetStream::Client.new

  # main event loops for matched tweets
  @client.track(TERMS) do |status|
    @tracked += 1
    puts status.text
  end

  # Error handling for Twitter streams.
  @client.on_error do |message|
    puts "ERROR: #{message}"
  end
  @client.on_enhance_your_calm do
    puts "TWITTER SAYZ ENHANCE UR CALM"
  end
  @client.on_limit do |skip_count|
    @skipped = skip_count
    puts "RATE LIMITED LOL"
  end
  @client.on_stall_warning do |warning|
    puts "STALL FALLBEHIND WARNING - NOT KEEPING UP WITH STREAM"
    puts warning
  end

  # Periodic logging to console/graphite - stream track status.
  @stats_refresh_rate = 10
  EM::PeriodicTimer.new(@stats_refresh_rate) do
    period = @tracked-@tracked_last
    period_rate = period / @stats_refresh_rate

    puts "Terms tracked: #{@tracked} (\u2191#{period}" +
         ", +#{period_rate}/sec.), rate limited: #{@skipped}" +
         " (+#{@skipped - @skipped_last})"
    @tracked_last = @tracked
    @skipped_last = @skipped