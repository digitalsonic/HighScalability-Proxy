require 'rubygems'
require 'sinatra'
require 'proxy'

include Proxy

BASE_URL = 'http://feeds.feedburner.com/HighScalability'

get '/' do	
	response = fetch BASE_URL
	links = parse_rss_item_links response.body
	real_links = []
	links.each { |l| real_links << get_clean_highscalability_url(translate_feedproxy_url_to_real_url(l[:link])) }
	content = ''
	real_links.each { |l| content += fetch_article_content(l) + '<hr/>' }
	body = "<html><body>#{content}</body></html>"
end

get '/rss' do
	response = fetch BASE_URL
	response.body
end