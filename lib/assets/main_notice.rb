def main_notice()
    puts '중앙공지'
    (0...10).step(10).each do |offset|
        list_url = "https://www.skku.edu/skku/campus/skk_comm/notice01.do?mode=list&&articleLimit=10&article.offset=#{offset}"
        #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 doc변수에 저장한다.
        list_doc = Nokogiri::HTML(open(list_url))
        new_notice_count = 0
        #.css selector로 공지의 href주소를 가져온다.
        a_tags = list_doc.css('tbody tr td.left a')
        
        #가장 최신의 글이 데이터베이스의 최신의 글의 링크와 다른가?
        if ("https://www.skku.edu/skku/campus/skk_comm/notice01.do"+a_tags.first['href']) != Notice.where(:group_id => 1).last.link
            puts "공지가 업데이트 되었습니다."
            a_tags.reverse.each do |a_tag|
                notice_href = a_tag['href']
                notice_url = "https://www.skku.edu/skku/campus/skk_comm/notice01.do"+notice_href
                if Notice.exists?(link: notice_url)
                    next
                else 
                
                    notice_doc = Nokogiri::HTML(open(notice_url))
                    
                    #Notice 정보
                    title = notice_doc.css('em.ellipsis').text
                    writer = notice_doc.css('li.noline').text
                    date = notice_doc.css('span.date').text.to_datetime
                    content = notice_doc.css('pre.pre')
            
                    #Notice 저장
                    Notice.create(
                        :link => notice_url,
                        :title => title,
                        :writer => writer,
                        :date => date,
                        :content => content,
                        :view => 100, #TODO: 고치기
                        :scrap_count => 0, #TODO: 물어보기
                        :group_id => 1
                        )
                        
                    #Attached 정보, 저장
                    files_a_tags = notice_doc.css('ul.filedown_list > li > a.ellipsis')
                    files_a_tags.each do |file_a_tag|
                        if (file_a_tag['href'] =~ /^http/)
                            file_url = file_a_tag['href']
                        else
                            file_url = "https://www.skku.edu/skku/campus/skk_comm/notice01.do"+file_a_tag['href']
                        end
                         Attached.create(:link => file_url, :name => file_a_tag.text, :notice_id => Notice.last.id)
                    end
                    
                    images = notice_doc.css('table.board_view img')
                    images.each do |image|
                        if (image['src'] =~ /^http/)
                            img_url = image['src']
                        else
                            img_url = "https://www.skku.edu"+image['src']
                        end
                        Image.create(:link => img_url, :notice_id => Notice.last.id)
                    end
                    new_notice_count += 1
                end
            end
            puts("#{new_notice_count}건의 공지가 동기화 되었습니다.")
        else
            puts("공지가 최신입니다.")
        end
        
    end
end