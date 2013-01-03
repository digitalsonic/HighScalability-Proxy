require 'rubygems'
require 'rss'
require 'eventmachine'
require 'em-http-request'
require File.join(File.dirname(__FILE__), 'proxy.rb')

class AsynchronousCacheProxy
	include Proxy

	CACHE_INTERVAL_SECONDS = 3600

	def initialize
		@cache = {}
	end

	def start url
		EM.run do
			scan url
			EM.add_periodic_timer(CACHE_INTERVAL_SECONDS) { scan url }
		end
	end

	def initialized?
		!@cache[:last_modified].nil?
	end

	def get_html_output
		body = "<body style=\"font-family: 'Times New Roman', Palatino, serif; text-align: left; background-color: white; margin: 50px; background-image: none; color: black; vertical-align: center;\">"
		@cache[:links].each { |link| body += (@cache[:contents][link][:body] + '<hr />') }
		body += '</body>'
		"<html><head>#{@cache[:head]}</head>#{body}</html>"
	end

	def get_rss_output
		rss = RSS::Maker.make('2.0') do |maker|
			maker.channel.author = "Todd Hoff"
			maker.channel.updated = Time.now.to_s
			maker.channel.about = HIGHSCALABILITY_URL
			maker.channel.link = HIGHSCALABILITY_URL
			maker.channel.description = "High Scalability Full Text RSS"
			maker.channel.title = "High Scalability"

			@cache[:links].each do |link|
				maker.items.new_item do |i|
					content = @cache[:contents][link]
					item = content[:item]
					i.link = link
					i.title = item[:title]
					i.updated = item[:pub_date]
					i.author = item[:author]
					i.description = content[:body]
				end
			end
		end
		rss.to_s
	end

	def get_origin_rss 
		@cache[:origin_rss]
	end
	
	private

	def scan url
		http = EM::HttpRequest.new(url).get(:redirects => 1)
		http.callback do
			puts "succeed fetching #{url}"
			items = parse_rss_items http.response
			get_all_articles items
			@cache[:origin_rss] = http.response
		end
	end

	def get_all_articles items
		contents = {}
		origin_items = {}
		items.each { |item| origin_items[get_clean_highscalability_url(item[:link])] = item }
		links = get_real_links items

		puts "fetching links: #{links}"
		head = nil
		multi = EM::MultiRequest.new
		links.each { |link| multi.add link, EM::HttpRequest.new(link).get }

		multi.callback do 
			multi.responses[:callback].each do |k, v| 
				head = replace_default_location(get_clean_html_part(v.response, 'head')) if head.nil?
				contents[k] = {:item => origin_items[k], :body => replace_default_location(get_clean_html_part(v.response, 'body')) }
			end
			@cache[:links] = links
			@cache[:head] = head
			@cache[:contents] = contents
			@cache[:last_modified] = Time.now
		end
	end
end