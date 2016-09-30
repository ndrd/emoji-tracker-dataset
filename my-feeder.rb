require 'tweetstream'
require 'emoji_data'


@client = Twitter::Streaming::Client.new do |config|
  config.consumer_key       = 'KRvH572Ep4usUK8eGOIKT5nLy'
  config.consumer_secret    = 'iLipr0DN5jBRAZgJkCXwQQMIFL90gfqLNBJN4GQGsMzmnDl0df'
  config.access_token        = '2385298681-W2l3LLZERhgrrlgIbFPpsSJkPNcQO3njU5La4wN'
  config.access_token_secret = '9aqz7p0rTRRX6qvHdFwnlkVKElr0zQs9HUsrIpsIisd4P'
end
# TweetStream::Client.new.track('term1', 'term2') do |status|
#   puts "#{status.text}"
# end

TERMS = ['el','la','de','que','y','a','en','un','ser','se','no','haber','por','con','su','para','como','estar','tener','le','lo','lo','todo','pero','mas','hacer','o','poder','decir','este','ir','otro','ese','la','si','me','ya','ver','porque','dar','cuando','el','muy','sin','vez','mucho','saber','que','sobre','mi','alguno','mismo','yo','tambien','hasta','año','dos','querer','entre','asi','primero','desde','grande','eso','ni','nos','llegar','pasar','tiempo','ella','si','dia','uno','bien','poco','deber','entonces','poner','cosa','tanto','hombre','parecer','nuestro','tan','donde','ahora','parte','despues','vida','quedar','siempre','creer','hablar','llevar','dejar','nada','cada','seguir','menos','nuevo']
@tracked,@skipped,@tracked_last,@skipped_last = 0,0,0,0

@client.filter(track: TERMS.join(","), locations: "-122.75,36.8,-121.75,37.8", languages: 'es') do |status|
	# disregard retweets
    next if status.retweet?
	hasEmoji = EmojiData.scan(status.text).length > 0
  	puts status.text if hasEmoji
end
