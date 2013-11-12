# #encoding: utf-8
require 'nokogiri'
require 'open-uri'

module Seo
	module Api
		module Analyse
			class LinkAnalyse
				def initialize(url="")
					@url = url
					@internal_links = []
					@external_links = []
					@internal_links, @external_links = get_links
					p @internal_links
				end

				def get_links url=""
					url = @url if(url="" || url.nil?)
					doc = Nokogiri::HTML(open(url))
					doc.css("a").each do |a|
						if(/com|cn|org|info|hk|co|uk/.match(URI.parse(url.to_s+a['href'].to_s).path).nil?)
							# if !@internal_links.include?(URI.parse(url.to_s+a['href'].to_s).path)
								@internal_links << URI.parse(url.to_s+a['href'].to_s).path
								p "---------"+URI.parse(url.to_s+a['href'].to_s).path if !@internal_links.include?(URI.parse(url.to_s+a['href'].to_s).path)
								get_links(URI.parse(url.to_s+a['href'].to_s))
							# end
						else
							@external_links << URI.parse(url.to_s+a['href'].to_s).path if !@external_links.include?(URI.parse(url.to_s+a['href'].to_s).path)
						end
					end
					return @internal_links, @external_links
				end
			end
		end
	end
end