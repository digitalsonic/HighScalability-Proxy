require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'asynchronous_cache_proxy.rb')

BASE_URL = 'http://feeds.feedburner.com/HighScalability'
# for test
# BASE_URL = 'http://highscalability-proxy.cloudfoundry.com/origin_rss'
HIGHSCALABILITY_URL = 'http://highscalability.com/'

proxy = AsynchronousCacheProxy.new
unstarted = true

before do
	cache_control :public, :max_age => 3600
end

get '/', :provides => 'html' do	
	if unstarted
		proxy.start BASE_URL
		unstarted = false
	end
	body = '<html><body><p align="center">Please wait for the initialization. </p></body></html>'
	body = proxy.get_html_output if proxy.initialized?
	body
end

get '/', :provides => ['rss', 'atom', 'xml'] do
	proxy.get_rss_output
end

get '/rss' do
	[200, {'Content-Type' => 'application/rss+xml'}, proxy.get_rss_output]
end

get '/origin_rss' do
	proxy.get_origin_rss
end