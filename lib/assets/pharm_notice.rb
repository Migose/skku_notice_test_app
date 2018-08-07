def pharm()
    puts '약학대학'
   list_uri = URI("http://pharm.skku.edu/board/board.jsp")
    (1..1).each do |page|
            list_req = Net::HTTP.post_form(
            list_uri,
            {
            "catg"=> "notice",
            "pageCnt"=> "10",
            "totalPage"=> "159",
            # "totalPage"=> "1",
            # "totalPage"=> "10",
            "curPage"=> "#{}",
            "pagePerCnt"=> "10",
            "srch_catg"=> "news_title",
            "srch_word"=> ""
            }
        )
        list_doc = Nokogiri::HTML(list_req.body)
        links = list_doc.css('tr a')
        links.each do |link|
            id = link['href'].scan(/\d+/).first
            notice_link = "http://pharm.skku.edu/board/view.jsp?curNum=#{id}"
            notice_doc = Nokogiri::HTML(open(notice_link))
            title = notice_doc.css('tr th').text
            writer = notice_doc.css("td.spoqa").text.scan(/｜(.+)날짜/).first.first
            date = notice_doc.css("td.spoqa").text.scan(/날짜｜(.+)조회수/).first.first.to_datetime
            view = notice_doc.css("td.spoqa").text.scan(/조회수｜(.+)/).first.first
            content = notice_doc.css('div#contents')
            
            Notice.create(
                :link => notice_link,
                :title => title,
                :writer => writer,
                :date => date,
                :content => content,
                :view => view,
                :scrap_count => 0, #TODO: 물어보기
                :group_id => 16
                )
                
            files = notice_doc.css('tr:nth-of-type(3) > td > a')
            files.each do |file|
                if (file['href'] =~ /^http/)
                    file_link = file['href']
                else
                    file_link = "http://pharm.skku.edu/board/"+file['href']
                end
                 Attached.create(:link => file_link, :name => file.text, :notice_id => Notice.last.id)
            end
            
            images = notice_doc.css('div#contents img')
            images.each do |image|
                if (image['src'] =~ /^http/)
                    img_link = image['src']
                else
                    img_link = "http://pharm.skku.edu"+image['src']
                end
                Image.create(:link => img_link, :notice_id => Notice.last.id)
            end
        end
    end 
end