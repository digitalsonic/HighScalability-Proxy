require 'rubygems'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/dublincore'
require 'net/http'
require 'uri'

module Proxy
	def fetch uri
		response = nil
		url = URI.parse(uri)
		Net::HTTP.start(url.host, url.port) do |http|
			path = url.path
			path += "?#{url.query}" unless url.query.nil?
			response = http.get(path)
			if (response == Net::HTTPRedirection or response == Net::HTTPFound)
				response = fetch response['location']
			end
		end
		response
	end

	def parse_rss_item_links full_rss
		links = []
		rss = RSS::Parser.parse full_rss, false
		rss.items.each { |item| links << {:title => item.title, :link => item.link} }
		links.delete_if { |link| link[:title].start_with?('Sponsored Post:') }
		links.each {|link| puts "#{link[:title]}: #{link[:link]}"}
		links
	end

	def translate_feedproxy_url_to_real_url url
		response = Net::HTTP.get_response(URI.parse(url))
		response['location']
	end

	def get_clean_highscalability_url uri
		url = URI.parse(uri)
		"#{url.scheme}://#{url.host}#{url.path}?printerFriendly=true"
	end

	def fetch_article_content url
		response = Net::HTTP.get_response(URI.parse(url))
		content = response.body
		#doc = Document.new(content)
		#doc.elements['//body'].elements.to_a
	end
end