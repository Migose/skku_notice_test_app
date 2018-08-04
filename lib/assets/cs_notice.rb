def cs()
    puts '소프트웨어 대학' 
    list_uri = URI("http://cs.skku.edu/ajax/board/list/notice")
    list_req = Net::HTTP.post_form(
        list_uri,
        {
        "Accept"=> "*/*",
        "Accept-Encoding"=> ["gzip", "deflate"],
        "Accept-Language"=> ["ko-KR","ko;q=0.9","en-US;q=0.8","en;q=0.7","de;q=0.6","es;q=0.5"],
        "Connection"=> "keep-alive",
        "Content-Length"=>"0",
        "Cookie"=> "_ga=GA1.2.369078695.1522732267; _gid=GA1.2.1693306267.1533285169; HOMEPAGE_JSESSIONID=3UMDdt7oLHDgx9bRgtvpxE1ZxGCCiCV6J_TjkDcD5Abs52YpRq6S!1654620447; connect.sid=s%3AW34AiV51KYOveU4fswQSXOs2RPjVPFWg.eGAczyhR0%2FlT0%2FoeisI91w9Vv4DysuKLFCsemFaFUfw; _gat=1",
        "Host"=> "cs.skku.edu",
        "Origin"=> "http://cs.skku.edu",
        "Referer"=> "http://cs.skku.edu/open/notice/list",
        "User-Agent"=> "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
        "X-Requested-With"=> "XMLHttpRequest"
        }
    )
    req_json = JSON.parse(list_req.body)
    req_json['aaData'].take(10).each do |notice|
        id = notice['id']
        notice_uri = URI("http://cs.skku.edu/ajax/board/view/notice/#{id}")
        notice_req = Net::HTTP.post_form(
            notice_uri,
            {
            "Accept"=> "*/*",
            "Accept-Encoding"=> ["gzip", "deflate"],
            "Accept-Language"=> ["ko-KR","ko;q=0.9","en-US;q=0.8","en;q=0.7","de;q=0.6","es;q=0.5"],
            "Connection"=> "keep-alive",
            "Content-Length"=>"0",
            "Cookie"=> "_ga=GA1.2.369078695.1522732267; _gid=GA1.2.1693306267.1533285169; HOMEPAGE_JSESSIONID=3UMDdt7oLHDgx9bRgtvpxE1ZxGCCiCV6J_TjkDcD5Abs52YpRq6S!1654620447; connect.sid=s%3AW34AiV51KYOveU4fswQSXOs2RPjVPFWg.eGAczyhR0%2FlT0%2FoeisI91w9Vv4DysuKLFCsemFaFUfw; _gat=1",
            "Host"=> "cs.skku.edu",
            "Origin"=> "http://cs.skku.edu",
            "Referer"=> "http://cs.skku.edu/open/notice/view/2359",
            "User-Agent"=> "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
            "X-Requested-With"=> "XMLHttpRequest"
            }
        )
        notice_json = JSON.parse(notice_req.body)
        
        title = notice_json['post']['title']
        content = notice_json['post']['text']
        view = notice_json['post']['views']
        writer = notice_json['post']['name']
        date = notice_json['post']['time']
        Notice.create(
                :title => title,
                :writer => writer,
                :date => date,
                :content => content,
                :view => view,
                :scrap_count => 0, #TODO: 물어보기
                :group_id => 15
                )
        
        notice_json['post']['files'].each do |file|
            if (file['link'] =~ /^http/)
                file_link = file['link']
            else
                file_link = "http://cs.skku.edu"+file['link']
            end
             Attached.create(:link => file_link, :name => file['name'], :notice_id => Notice.last.id)
        end
        
        image_doc = Nokogiri::HTML(notice_json['post']['text'])
        image_doc.css('img').each do |image|
            if (image['src'] =~ /^http/)
                img_url = image['src']
            else
                img_url = "http://cs.skku.edu"+image['src']
            end
            Image.create(:link => img_url, :notice_id => Notice.last.id)
        end
    end


end