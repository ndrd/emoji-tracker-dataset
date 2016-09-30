require 'tweetstream'
require 'emoji_data'
require 'cld'
require 'eventmachine'

Thread.abort_on_exception = true

@client = Twitter::Streaming::Client.new do |config|
	config.consumer_key       = 'KRvH572Ep4usUK8eGOIKT5nLy'
	config.consumer_secret    = 'iLipr0DN5jBRAZgJkCXwQQMIFL90gfqLNBJN4GQGsMzmnDl0df'
	config.access_token        = '2385298681-W2l3LLZERhgrrlgIbFPpsSJkPNcQO3njU5La4wN'
	config.access_token_secret = '9aqz7p0rTRRX6qvHdFwnlkVKElr0zQs9HUsrIpsIisd4P'
end

emoji_name = ["SMILING FACE WITH HEART-SHAPED EYES","LOUDLY CRYING FACE","SMILING FACE WITH SMILING EYES","UNAMUSED FACE","FACE THROWING A KISS","TWO HEARTS","WHITE SMILING FACE","WEARY FACE","OK HAND SIGN","PENSIVE FACE","SMIRKING FACE","GRINNING FACE WITH SMILING EYES","BLACK UNIVERSAL RECYCLING SYMBOL","WINKING FACE","THUMBS UP SIGN","PERSON WITH FOLDED HANDS","RELIEVED FACE","MULTIPLE MUSICAL NOTES","FLUSHED FACE","PERSON RAISING BOTH HANDS IN CELEBRATION","CRYING FACE","SMILING FACE WITH SUNGLASSES","SEE-NO-EVIL MONKEY","EYES","VICTORY HAND","SMILING FACE WITH OPEN MOUTH AND COLD SWEAT","SPARKLES","BROKEN HEART","PURPLE HEART","SLEEPING FACE","SMILING FACE WITH OPEN MOUTH AND SMILING EYES","HUNDRED POINTS SYMBOL","EXPRESSIONLESS FACE","SPARKLING HEART","BLUE HEART","CONFUSED FACE","FACE WITH STUCK-OUT TONGUE AND WINKING EYE","DISAPPOINTED FACE","INFORMATION DESK PERSON","FACE SAVOURING DELICIOUS FOOD","NEUTRAL FACE","LEFTWARDS BLACK ARROW","SLEEPY FACE","CLAPPING HANDS SIGN","HEART WITH ARROW","GROWING HEART","REVOLVING HEARTS","SPEAK-NO-EVIL MONKEY","KISS MARK","RAISED HAND","WHITE RIGHT POINTING BACKHAND INDEX","CHERRY BLOSSOM","FACE SCREAMING IN FEAR","FIRE","SMILING FACE WITH HORNS","POUTING FACE","CAMERA","SMILING FACE WITH OPEN MOUTH","PARTY POPPER","TIRED FACE","FISTED HAND SIGN","ROSE","SKULL","FACE WITH STUCK-OUT TONGUE AND TIGHTLY-CLOSED EYES","FLEXED BICEPS","YELLOW HEART","BLACK SUN WITH RAYS","FACE WITH LOOK OF TRIUMPH","NEW MOON WITH FACE","SMILING FACE WITH OPEN MOUTH AND TIGHTLY-CLOSED EYES","FACE WITH COLD SWEAT","WHITE LEFT POINTING BACKHAND INDEX","HEAVY CHECK MARK","SMILING CAT FACE WITH HEART-SHAPED EYES","GRINNING FACE","GREEN HEART","FACE WITH MEDICAL MASK","PERSEVERING FACE","BLACK RIGHT-POINTING TRIANGLE","WAVING HAND SIGN","BEATING HEART","KISSING FACE WITH CLOSED EYES","CROWN","FACE WITH STUCK-OUT TONGUE","DISAPPOINTED BUT RELIEVED FACE","SMILING FACE WITH HALO","BLACK RIGHTWARDS ARROW","HEADPHONE","WHITE HEAVY CHECK MARK","CONFOUNDED FACE","ANGRY FACE","GRIMACING FACE","GLOWING STAR","HAPPY PERSON RAISING ONE HAND","PISTOL","KEYCAP 1","THUMBS DOWN SIGN"]
#emoji_name = ["SMILING FACE WITH HEART-SHAPED EYES","LOUDLY CRYING FACE","SMILING FACE WITH SMILING EYES","UNAMUSED FACE","FACE THROWING A KISS","TWO HEARTS","WHITE SMILING FACE","WEARY FACE","OK HAND SIGN","PENSIVE FACE","SMIRKING FACE","GRINNING FACE WITH SMILING EYES","BLACK UNIVERSAL RECYCLING SYMBOL","WINKING FACE","THUMBS UP SIGN","PERSON WITH FOLDED HANDS","RELIEVED FACE","MULTIPLE MUSICAL NOTES","FLUSHED FACE","PERSON RAISING BOTH HANDS IN CELEBRATION","CRYING FACE","SMILING FACE WITH SUNGLASSES","SEE-NO-EVIL MONKEY","EYES","VICTORY HAND","SMILING FACE WITH OPEN MOUTH AND COLD SWEAT","SPARKLES","BROKEN HEART","PURPLE HEART","SLEEPING FACE","SMILING FACE WITH OPEN MOUTH AND SMILING EYES","HUNDRED POINTS SYMBOL","EXPRESSIONLESS FACE","SPARKLING HEART","BLUE HEART","CONFUSED FACE","FACE WITH STUCK-OUT TONGUE AND WINKING EYE","DISAPPOINTED FACE","INFORMATION DESK PERSON","FACE SAVOURING DELICIOUS FOOD","NEUTRAL FACE","LEFTWARDS BLACK ARROW","SLEEPY FACE","CLAPPING HANDS SIGN","HEART WITH ARROW","GROWING HEART","REVOLVING HEARTS","SPEAK-NO-EVIL MONKEY","KISS MARK","RAISED HAND","WHITE RIGHT POINTING BACKHAND INDEX","CHERRY BLOSSOM","FACE SCREAMING IN FEAR","FIRE","SMILING FACE WITH HORNS","POUTING FACE","CAMERA","SMILING FACE WITH OPEN MOUTH","PARTY POPPER","TIRED FACE","FISTED HAND SIGN","ROSE","SKULL","FACE WITH STUCK-OUT TONGUE AND TIGHTLY-CLOSED EYES","FLEXED BICEPS","YELLOW HEART","BLACK SUN WITH RAYS","FACE WITH LOOK OF TRIUMPH","NEW MOON WITH FACE","SMILING FACE WITH OPEN MOUTH AND TIGHTLY-CLOSED EYES","FACE WITH COLD SWEAT","WHITE LEFT POINTING BACKHAND INDEX","HEAVY CHECK MARK","SMILING CAT FACE WITH HEART-SHAPED EYES","GRINNING FACE","GREEN HEART","FACE WITH MEDICAL MASK","PERSEVERING FACE","BLACK RIGHT-POINTING TRIANGLE","WAVING HAND SIGN","BEATING HEART","KISSING FACE WITH CLOSED EYES","CROWN","FACE WITH STUCK-OUT TONGUE","DISAPPOINTED BUT RELIEVED FACE","SMILING FACE WITH HALO","BLACK RIGHTWARDS ARROW","HEADPHONE","WHITE HEAVY CHECK MARK","CONFOUNDED FACE","ANGRY FACE","GRIMACING FACE","GLOWING STAR","HAPPY PERSON RAISING ONE HAND","PISTOL","KEYCAP 1","THUMBS DOWN SIGN"]
terms = []
emoji_tmp = []

emoji_name.each do |v|
	terms << EmojiData.find_by_name(v).map { |c| c.render }
end

terms =  terms.flat_map {|i| i}

puts terms.to_s

@g_tracked, @g_last_tracked = 0,0

def get_tweets(terms.join(','))
	puts "starting at: #{Time.now} for terms: " +  terms.to_s 
	@tracked,@no_emojis,@has_emojis,@total = 0,0,0,0

	@tweets_with_emojis = []
	@tweets_without_emojis = []

	@client.filter(track: [terms].join(',')) do |status|
	    next if status.retweet?
	    language =  CLD.detect_language(status.text)
	    isSpanish = false

	    language.each do |k,v|
	    	isSpanish =  v == 'SPANISH' 
	    	break if isSpanish
	    end

	    next if not isSpanish
	    puts status.text
		
		emojis = EmojiData.scan(status.text)
		next if emojis.length == 0

		text = status.text.dup
		emojis.each do |e|
			begin  
				text =  text.gsub!(e.render, (e.name.gsub(/\s+/, '_')))
			rescue Exception => e
			end
		end

		@tweets_without_emojis <<  text
		@total += 1
		@g_tracked =  @total

		if @total % 200 == 0
			puts text
			puts 'Another 200'
		end

		if @total % 1000 == 0 and @total > 0
			puts "Saving batch " + @total.to_s
			File.open('data/emoji_' + Time.now.utc.iso8601, 'w:UTF-8') do |file|
				@tweets_without_emojis.each do |tweet|
					begin  
						text = tweet.gsub(/\r\n?/, "")
						text = text.gsub(/@([a-z0-9_]+)/i, "")
						text = text.gsub(/#([a-z0-9_]+)/i, "")
						text = text.gsub(/(?:f|ht)tps?:\/[^\s]+/, '')
						file.write(text + "\n")
					rescue Exception => e  

					end  
				end
			end
			@tweets_without_emojis = []
		end

		if  @total === 100000
			return false
		end

	end
end

get_tweets(terms)

