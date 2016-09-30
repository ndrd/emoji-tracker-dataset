require 'tweetstream'
require 'emoji_data'
require 'cld'

@client = Twitter::Streaming::Client.new do |config|
  config.consumer_key       = 'KRvH572Ep4usUK8eGOIKT5nLy'
  config.consumer_secret    = 'iLipr0DN5jBRAZgJkCXwQQMIFL90gfqLNBJN4GQGsMzmnDl0df'
  config.access_token        = '2385298681-W2l3LLZERhgrrlgIbFPpsSJkPNcQO3njU5La4wN'
  config.access_token_secret = '9aqz7p0rTRRX6qvHdFwnlkVKElr0zQs9HUsrIpsIisd4P'
end

TERMS = ['el','la','de','que','y','a','en','un','ser','se','no','haber','por','con','su','para','como','estar','tener','le','lo','lo','todo','pero','mas','hacer','o','poder','decir','este','ir','otro','ese','la','si','me','ya','ver','porque','dar','cuando','el','muy','sin','vez','mucho','saber','que','sobre','mi','alguno','mismo','yo','tambien','hasta','año','dos','querer','entre','asi','primero','desde','grande','eso','ni','nos','llegar','pasar','tiempo','ella','si','dia','uno','bien','poco','deber','entonces','poner','cosa','tanto','hombre','parecer','nuestro','tan','donde','ahora','parte','despues','vida','quedar','siempre','creer','hablar','llevar','dejar','nada','cada','seguir','menos','nuevo']
@tracked,@no_emojis,@has_emojis,@total = 0,0,0,0

@tweets_with_emojis = []
@tweets_without_emojis = []

@client.filter(track: TERMS.join(",")) do |status|
    next if status.retweet?
    language =  CLD.detect_language(status.text)
    isSpanish = false

    language.each do |k,v|
    	isSpanish =  v == 'SPANISH' 
    	break if isSpanish
    end

    next if not isSpanish
	
	emojis = EmojiData.scan(status.text)
	next if emojis.length > 0

	@tweets_without_emojis <<  status.text.dup
	@total += 1

	if @total % 20000 == 0 and @total > 0
		puts "Saving batch " + @total.to_s
		File.open('data/emoji_' + Time.now.utc.iso8601, 'w:UTF-8') do |file|
			@tweets_without_emojis.each do |tweet|
				text = tweet.gsub(/\r\n?/, "")
				text = text.gsub(/@([a-z0-9_]+)/i, "")
				text = text.gsub(/#([a-z0-9_]+)/i, "")
				text = text.gsub(/(?:f|ht)tps?:\/[^\s]+/, '')
				file.write(text + "\n")
			end
		end
		@tweets_without_emojis = []
	end

	if  @total === 200000
		return false
	end

end
