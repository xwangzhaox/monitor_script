#coding: utf-8
require 'nokogiri'
require 'open-uri'

class GetContent
	def get_content
		base_url = "http://www.23us.com/html/11/11104/15107959.html"
		# base_url = "http://www.23us.com/html/11/11104/15107638.html"
		# ic = Iconv.new("utf-8//translit//IGNORE","big5")
		# logfile = File.open("book.txt", "a")
		doc = Nokogiri::HTML(open(base_url))
		# doc.css("td a").each do |a|
		# 	p a.content
		# end
		p doc.css("dd#contents").first.content
		# doc.encoding = 'gb2312'
		# doc.css("td a").each do |a|
		# 	url =base_url.to_s+a['href'].to_s
		# 	doc_content = Nokogiri::HTML.parse(open(url), nil, 'gb2312')
		# 	logfile. puts "\n\n"+a.content+"\n\n"
		# 	logfile.puts doc_content.css("dd#contents").first.content+"\n"
		# end
		# logfile.close
	end
end

book = GetContent.new
book.get_content