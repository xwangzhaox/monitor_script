#coding: utf-8
require 'nokogiri'
require 'open-uri'

class GetContent
	def get_content
		book = ""
		base_url = "http://www.xixingyu.com/"
		doc = Nokogiri::HTML.parse(open(base_url), nil, 'UTF-8')
		doc.search("tbody a").each do |a|
			doc_content = Nokogiri::HTML.parse(open(a['href']), nil, 'UTF-8')
			book += doc_content.css("div.bg h1").first.content+"\n"
			doc_content.search("div.bg .content p").each do |xx|
				next if xx.content.length==0 || xx.content.index(/名字 (必填)*/)==0 || xx.content.index(/\r\n下一篇/)==0 || xx.content.index(/\r\n上一篇/)==0
				book += xx.content+"\n"
			end
		end
		
		logfile = File.open("book.txt", "a")
			logfile.puts book
		logfile.close
	end
end

book = GetContent.new
book.get_content