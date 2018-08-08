def pharm()
    puts '약학대학'
    (1..1).each do |page|
            list_req = Net::HTTP.post_form(
            URI("http://pharm.skku.edu/board/board.jsp"),
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
        a_tags = list_doc.css('tr a')
        if ("http://pharm.skku.edu/board/view.jsp?curNum="+a_tags.first['href'].scan(/\d+/).first) != Notice.where(:group_id => 16).last.link
            puts "공지가 업데이트 되었습니다."
            a_tags.reverse.each do |a_tag|
                id = a_tag['href'].scan(/\d+/).first
                notice_url = "http://pharm.skku.edu/board/view.jsp?curNum=#{id}"
                if Notice.exists?(link: notice_url)
                    next
                else
                    
                    notice_doc = Nokogiri::HTML(open(notice_url))
                    title = notice_doc.css('tr th').text
                    writer = notice_doc.css("td.spoqa").text.scan(/｜(.+)날짜/).first.first
                    date = notice_doc.css("td.spoqa").text.scan(/날짜｜(.+)조회수/).first.first.to_datetime
                    view = notice_doc.css("td.spoqa").text.scan(/조회수｜(.+)/).first.first
                    content = notice_doc.css('div#contents')
                    
                    Notice.create(
                        :link => notice_url,
                        :title => title,
                        :writer => writer,
                        :date => date,
                        :content => content,
                        :view => view,
                        :scrap_count => 0, #TODO: 물어보기
                        :group_id => 16
                        )
                        
                    files_a_tags = notice_doc.css('tr:nth-of-type(3) > td > a')
                    files_a_tags.each do |file_a_tag|
                        if (file_a_tag['href'] =~ /^http/)
                            file_url = file_a_tag['href']
                        else
                            file_url = "http://pharm.skku.edu/board/"+file_a_tag['href']
                        end
                         Attached.create(:link => file_url, :name => file_a_tag.text, :notice_id => Notice.last.id)
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
                    new_notice_count += 1
                end
            end
            puts("#{new_notice_count}건의 공지가 동기화 되었습니다.")
        else
            puts "공지가 최신입니다."
        end
    end 
end