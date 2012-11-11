require 'rubygems'
require 'sinatra'
require 'rss'
require 'proxy'

include Proxy

BASE_URL = 'http://feeds.feedburner.com/HighScalability'
HIGHSCALABILITY_URL = 'http://highscalability.com/'
CACHE_EXPIRES = 3600

body_cache = {:last_modified => Time.now - CACHE_EXPIRES, :obj => nil}
rss_cache = {:last_modified => Time.now - CACHE_EXPIRES, :obj => nil}

before do
	cache_control :public, :max_age => 3600
end

get '/' do	
	if need_refresh_cache(body_cache)
		response = fetch BASE_URL
		items = parse_rss_items response.body
		real_links = []
		items.each { |i| real_links << get_clean_highscalability_url(i[:link]) }
		body = ''
		head = nil
		real_links.each do |l| 
			origin = fetch_article_content(l)
			head = replace_default_location(get_clean_html_part(origin, 'head')) if head.nil?
			body += replace_default_location(get_clean_html_part(origin, 'body')) + '<hr/>' 
		end
		body = "<html>#{head}<body style=\"font-family: 'Times New Roman', Palatino, serif; text-align: left; background-color: white; margin: 50px; background-image: none; color: black; vertical-align: center;\">#{body}</body></html>"
		refresh_cache(body_cache, body)
	end
	body_cache[:obj]
end

get '/rss' do
	if need_refresh_cache(rss_cache)
		response = fetch BASE_URL
		items = parse_rss_items response.body
		rss = RSS::Maker.make('2.0') do |maker|
			maker.channel.author = "Todd Hoff"
			maker.channel.updated = Time.now.to_s
			maker.channel.about = HIGHSCALABILITY_URL
			maker.channel.link = HIGHSCALABILITY_URL
			maker.channel.description = "High Scalability Full Text RSS"
			maker.channel.title = "High Scalability"
	
			items.each do |item|
				maker.items.new_item do |i|
					i.link = get_clean_highscalability_url(item[:link])
					i.title = item[:title]
					i.updated = item[:pub_date]
					i.author = item[:dc_creator]
					i.description = get_clean_html_part(fetch_article_content(i.link), 'body')
				end
			end
		end
		rss_cache[:obj] = [200, {'Content-Type' => 'application/rss+xml'}, rss.to_s]
	end
	rss_cache[:obj]
end

get '/origin_rss' do 
	response = fetch BASE_URL
	response.body
end