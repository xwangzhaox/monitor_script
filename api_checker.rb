require "nokogiri"
require "open-uri"
require "net/smtp"
require "mysql"

class ApiCheck
	def check_data
		for_one()
		for_two()
	end

	def for_two
		daliy_data_count = {:baidu_report=>"60", :yahoo_report=>"80", :google_report=>"170", :sogou_report=>"8"}
		queues_job_count = check_queues_job()
		reports = {}
		reports[:baidu_reports] = []
		reports[:google_reports] = []
		reports[:yahoo_reports] = []
		reports[:sogou_reports] = []

		queues_job_count.each do |searchengine_report|
			sql = "select searchengine, searchengines.id, last_report_update_date, keywordhists.* from keywordhists 
inner join searchengines on searchengines.id=keywordhists.searchengine_id
where k_date=#{(Time.now-24*3600).strftime('%Y%m%d')} and searchengine='#{searchengine_report.first.split('_').first}'
group by searchengine_id order by last_report_update_date"
			conn = Mysql.new("10.1.1.130", "xmo_readonly", "Tmac360doaS", "xmo")
			result = conn.query(sql)
			result.each do |row|
				reports[(searchengine_report.first+"s").to_sym]<<row
			end

			if searchengine_report[1]=="0"
				min = daliy_data_count[searchengine_report[0].to_sym].to_i-5
				val = reports[(searchengine_report.first+"s").to_sym].length
				max = daliy_data_count[searchengine_report[0].to_sym].to_i+5
				if min>=val && val>=max	
					#ERROR
					content = "<h2>Data error!</h2>
							<p>Wrong item 2</p>
							<p>#{searchengine_report.first} records count is #{reports[(searchengine_report.first+"s").to_sym].length }. #{min<=val ? 'Greater' : 'Less'} than #{ min<=val ? 'max value '+max.to_s : 'mix value '+mix.to_s}</p>"
					sendemail("ApiCheck", content) 
				end
			end
		end

		if Time.now-Time.parse(reports[:yahoo_reports].last[2])>300
			content = "<h2>Data error!</h2>
							<p>Wrong item 2</p>
							<p>The last Yahoo record's [last_report_update_date] is far cry from [Time.now]</p>
							<p><strong>Send Email Time:</strong> #{Time.now}</p>
							<p><strong>Yahoo record's [last_report_update_date] Time:</strong> #{Time.parse(reports[:yahoo_reports].last[2])}</p>"
			sendemail("ApiCheck", content) 
		end
	end

	def for_one
		arr_1=[]
		arr_2=[]

		arr_1=check_queues_job()
		sleep(300)
		arr_2=check_queues_job()
		arr_1.collect{|x| x[1]}.length.times do |int|
			if arr_1.collect{|x| x[1]}[int]!="0" and arr_1.collect{|x| x[1]}[int]==arr_2.collect{|x| x[1]}[int]
				content = "<h2>Data error!</h2>
							<p>Wrong item 1</p>
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
							<p>Check url: http://10.1.1.54:2868/queues</p>"
				sendemail("ApiCheck", content) 
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

	def sendemail(subject, content)    
		from = "kevin.wang@i-click.cn"
		to = ["kevin.wang@i-click.cn", "jason.li@i-click.cn", "jay.liu@i-click.cn"]
		msg = <<MESSAGE_END
From: kevin.wang@i-click.cn <kevin.wang@i-click.cn>
To: kevin.wang@i-click.cn <kevin.wang@i-click.cn>, jason.li@i-click.cn <jason.li@i-click.cn>, jay.liu@i-click.cn <jay.liu@i-click.cn>
MIME-Version: 1.0
Content-type: text/html
Subject: #{Time.now.strftime("%Y-%m-%d")} #{subject}

#{content}
MESSAGE_END
	    smtp = Net::SMTP.start("smtp.qiye.163.com",25,"163.com", "kevin.wang@i-click.cn", "sruce3g", :login)  
	    smtp.send_message msg,from,to  
	    smtp.finish  
	end 
end

c = ApiCheck.new
c.check_data

