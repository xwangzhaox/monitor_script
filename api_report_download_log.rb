require "mysql"
require 'pg'
require 'time'
require "net/smtp"

class ApiReportDownloadLog
	def output_date_to_mail

		val_1 = get_mysql_date()
		val_2 = get_pg_date()

		msg = <<MESSAGE_END
From: kevin.wang@i-click.cn <kevin.wang@i-click.cn>
To: kevin.wang@i-click.cn <kevin.wang@i-click.cn>
MIME-Version: 1.0
Content-type: text/html
Subject: #{Time.now.strftime("%Y-%m-%d")} Api Report Download Log

<table border="1" style="border-collapse: collapse" bordercolor:"#333333" cellspacing="0">
	<tr>
		<td rowspan='2'><p><strong>Date</strong></p></td>
		<td colspan='4'><p><strong>Baidu</strong></p></td>
		<td colspan='4'><p><strong>Yahoo</strong></p></td>
		<td colspan='4'><p><strong>Google</strong></p></td>
		<td colspan='4'><p><strong>Sogou</strong></p></td>
		<td><p><strong>Remark</strong></p></td>
	</tr>
	<tr>
		<td><p><strong>Start</strong></p></td>
		<td><p><strong>End</strong></p></td>
		<td><p><strong>Duration (Min)</strong></p></td>
		<td><p><strong># of accounts</strong></p></td>
		<td><p><strong>Start Time</strong></p></td>
		<td><p><strong>End Time</strong></p></td>
		<td><p><strong>Duration (Min)</strong></p></td>
		<td><p><strong># of accounts</strong></p></td>
		<td><p><strong>Start Time</strong></p></td>
		<td><p><strong>End Time</strong></p></td>
		<td><p><strong>Duration (Min)</strong></p></td>
		<td><p><strong># of accounts</strong></p></td>
		<td><p><strong>Start Time</strong></p></td>
		<td><p><strong>End Time</strong></p></td>
		<td><p><strong>Duration (Min)</strong></p></td>
		<td><p><strong># of accounts</strong></p></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		
		<td><p>#{Time.now.strftime("%Y%m%d")}</p></td>
		<td>06:10</td>
		<td>#{val_2[:baidu]}</td>
		<td>#{((Time.parse(val_2[:baidu])-Time.parse("06:10"))/60).to_i}</td>
		<td>#{val_1[:baidu]}</td>
		<td>05:00</td>
		<td>#{val_2[:yahoo]}</td>
		<td>#{((Time.parse(val_2[:yahoo])-Time.parse("05:00"))/60).to_i}</td>
		<td>#{val_1[:yahoo]}</td>
		<td>05:00</td>
		<td>#{val_2[:google]}</td>
		<td>#{((Time.parse(val_2[:google])-Time.parse("05:00"))/60).to_i}</td>
		<td>#{val_1[:google]}</td>
		<td>08:20</td>
		<td>#{val_2[:sogou]}</td>
		<td>#{((Time.parse(val_2[:sogou])-Time.parse("08:20"))/60).to_i}</td>
		<td>#{val_1[:sogou]}</td>
		<td></td>
	</tr>
</table>
MESSAGE_END

		from = "kevin.wang@i-click.cn"
		to = ["kevin.wang@i-click.cn", "jason.li@i-click.cn", "jay.liu@i-click.cn"]
		# msg = "Subject: "+"subject" +"\n\n"+content
	    smtp = Net::SMTP.start("smtp.qiye.163.com",25,"163.com", "kevin.wang@i-click.cn", "sruce3g", :login)  
	    smtp.send_message msg,from,to  
	    smtp.finish  
	    

	end

	def get_mysql_date
		val = {}
		sql = "select searchengine, count(distinct se.id) 
			from adgrouphists ah inner join searchengines se 
			on ah.searchengine_id = se.id 
			where report_date_i >= #{(Time.now-4*24*3600).strftime("%Y%m%d")}
			and apiinbound = 1
			and status = 'Active'
			and searchengine in ('Google', 'Yahoo', 'Baidu', 'Sogou') group by 1"
		my = Mysql.new("10.1.1.130", "xmo_readonly", "Tmac360doaS", "xmo")
		res = my.query(sql)
		res.each do |row|
			val[row.first.downcase.to_sym] = row.last
		end
		return val
	end

	def get_pg_date
		val = {}
		sql = "select se.searchengine, max(kh.created_at) + interval '8 hours' 
			from keywordhists kh inner join searchengines se on kh.searchengine_id = se.id 
			where k_date = #{(Time.now-1*24*3600).strftime("%Y%m%d")}
			and apiinbound = 1
			and status = 'Active'
			and searchengine in ('Google', 'Yahoo', 'Baidu', 'Baidu Display', 'Sogou')
			group by 1 order by 1"
		conn = PGconn.connect("10.1.1.73", 5432, '', '', "xmo_dw", "jay_liu", "ZLfr.cr0")
		res  = conn.exec(sql)

		res.each do |row|
			val[row["searchengine"].downcase.to_sym] = Time.parse(row["?column?"]).strftime("%H:%M")
		end
		return val
	end

end

a = ApiReportDownloadLog.new
a.output_date_to_mail