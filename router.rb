require 'rubygems'
require 'sinatra'
require 'rss'
require 'proxy'

include Proxy

BASE_URL = 'http://feeds.feedburner.com/HighScalability'

before do
	cache_control :public, :max_age => 600
	puts "access log - #{Time.now} - #{request.ip} - #{request.url} - #{request.user_agent}"
end

get '/' do	
	response = fetch BASE_URL
	items = parse_rss_items response.body
	real_links = []
	items.each { |i| real_links << get_clean_highscalability_url(i[:link]) }
	body = ''
	head = nil
	real_links.each do |l| 
		origin = fetch_article_content(l)
		head = get_clean_html_part(origin, 'head') if head.nil?
		body += get_clean_html_part(origin, 'body') + '<hr/>' 
	end
	body = "<html>#{head}<body>#{body}</body></html>"
end

get '/rss' do
	response = fetch BASE_URL
	items = parse_rss_items response.body
	rss = RSS::Maker.make('2.0') do |maker|
		maker.channel.author = "Todd Hoff"
		maker.channel.updated = Time.now.to_s
		maker.channel.about = "http://highscalability.com/"
		maker.channel.link = "http://highscalability.com/"
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
	[200, {'Content-Type' => 'application/rss+xml'}, rss.to_s]
end

get '/origin_rss' do 
	response = fetch BASE_URL
	response.body
end