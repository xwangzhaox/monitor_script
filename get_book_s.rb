#encoding: utf-8
require 'nokogiri'
require 'open-uri'

class GetContent
	def get_content
		base_url = "http://www.webcircletech.com/"
		# logfile = File.open("book1.txt", "a")
		doc = Nokogiri::HTML(open(base_url))
		doc.css("a").each do |a|
			p url =base_url.to_s+a['href'].to_s
			# doc_content = Nokogiri::HTML.parse(open(url))
			# logfile.puts "\n\n"+a.content+"\n\n"
			# if doc_content.css("dd#contents").length!=0 
				# logfile.puts doc_content.css("dd#contents").first.content+"\n"
			# end
		end
		# logfile.close
	end
end

book = GetContent.new
book.get_content