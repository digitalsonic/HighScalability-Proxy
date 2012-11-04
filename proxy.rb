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

	def parse_rss_items full_rss
		items = []
		rss = RSS::Parser.parse full_rss, false
		rss.items.each { |item| items << {:title => item.title, :link => item.link, :pubDate => item.pubDate, :dc_creator => item.dc_creator} }
		items.delete_if { |item| item[:title].start_with?('Sponsored Post:') }
		items
	end

	def get_clean_highscalability_url uri
		response = Net::HTTP.get_response(URI.parse(uri))
		url = URI.parse(response['location'])
		"#{url.scheme}://#{url.host}#{url.path}?printerFriendly=true"
	end

	def fetch_article_content url
		response = Net::HTTP.get_response(URI.parse(url))
		response.body
	end

	def get_clean_head html
		head = ""
		is_head = false
		html.each_line do |line|
			if line =~ /^.*<head.*$/
				is_head = true 
				next
			end
			break if line =~ /^.*<\/head.*$/
			head += line if is_head
		end
		head
	end

	def get_clean_body html
		body = ""
		is_body = false
		html.each_line do |line|
			if line =~ /^.*<body.*$/
				is_body = true 
				next
			end
			break if line =~ /^.*<\/body.*$/
			body += line if is_body
		end
		body
	end
end