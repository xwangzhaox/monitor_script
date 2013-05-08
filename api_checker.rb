require "nokogiri"
require "open-uri"
require "net/smtp"

class ApiCheck
	def check_data
		arr_1=[]
		arr_2=[]
		arr_1=check_queues_job()
		sleep(300)
		arr_2=check_queues_job()
		arr_1.collect{|x| x[1]}.length.times do |int|
			if arr_1.collect{|x| x[1]}[int]!="0" and arr_1.collect{|x| x[1]}[int]==arr_2.collect{|x| x[1]}[int]
				sendemail("ApiCheck", arr_1, arr_2) 
			end
		end
	end

	def check_queues_job
		url = "http://10.1.1.54:2868/queues"
		doc = Nokogiri::HTML.parse(open(url), nil, 'gb2312')
		arr = []
		doc.search("table tr").each do |xx|
		  arr << xx.content.partition("\n").collect {|x|x.strip.chomp} if xx.content.include? "baidu_report" or xx.content.include? "google_report" or xx.content.include? "yahoo_report" or xx.content.include? "sogou_report"
		end
		return arr.each {|x| x.delete_at(1)}
	end

	def sendemail(subject, arr_1, arr_2)    
		from = "kevin.wang@i-click.cn"
		to = ["kevin.wang@i-click.cn", "jason.li@i-click.cn", "jay.liu@i-click.cn"]
		msg = <<MESSAGE_END
From: kevin.wang@i-click.cn <kevin.wang@i-click.cn>
To: kevin.wang@i-click.cn <kevin.wang@i-click.cn>
MIME-Version: 1.0
Content-type: text/html
Subject: #{Time.now.strftime("%Y-%m-%d")} #{subject}

<p>Data error!</p>
<table>
	<tr>
		<td>#{Time.now-300}</td>
		<td>#{arr_1}</td>
	</tr>
	<tr>
		<td>#{Time.now}</td>
		<td>#{arr_2}</td>
	</tr>
</table>
<p>Check url: http://10.1.1.54:2868/queues</p>
MESSAGE_END
	    smtp = Net::SMTP.start("smtp.qiye.163.com",25,"163.com", "kevin.wang@i-click.cn", "sruce3g", :login)  
	    smtp.send_message msg,from,to  
	    smtp.finish  
	end 
end

c = ApiCheck.new
c.check_data

