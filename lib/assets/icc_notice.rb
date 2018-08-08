def icc()
    puts'정보통신대학'
    (1..1).each do |page|
        list_url ="http://icc.skku.ac.kr/icc_new/board_list_square?listPage=#{page}&boardName=board_notice&field=subject&keyword="
        #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 doc변수에 저장한다.
        list_doc = Nokogiri::HTML(open(list_url))
        new_notice_count = 0
        #.css selector로 a태그들을 XML::Nodeset 형태로 가져와 href만 배열에 저장한다.
        a_tags = list_doc.css("td.board-title a")
        if ("http://icc.skku.ac.kr/icc_new/"+a_tags.first['href']) != Notice.where(:group_id => 13).last.link
            puts "공지가 업데이트 되었습니다."
            a_tags.reverse.each do |a_tag|
                notice_url = "http://icc.skku.ac.kr/icc_new/"+a_tag['href']
                
                if Notice.exists?(link: notice_url)
                    next
                else
                    notice_doc = Nokogiri::HTML(open(notice_url))
                    #Notice 정보
                    title = notice_doc.css("td#subject").text
                    writer = notice_doc.css("td#writer").text
                    date = notice_doc.css("td#time").text.to_datetime
                    view = 0 #TODO: 조회수 수정
                    content = notice_doc.css('td#content')
                    
                    #Notice 저장
                    Notice.create!(
                        :link => notice_url,
                        :title => title,
                        :writer => writer,
                        :date => date,
                        :content => content,
                        :view => view,
                        :scrap_count => 0, #TODO: 물어보기
                        :group_id => 13
                        #:keyword_id => 1, #TODO: ??
                        #:user_id => 1 #TODO: ??
                        )
                        
                    #Attached 정보, 저장
                    files_a_tags = notice_doc.css('td.attachment a')
                    files_a_tags.each do |file_a_tag|
                        if (file_a_tag['href'] =~ /^http/)
                            file_url = file_a_tag['href']
                        else
                            file_url = "http://icc.skku.ac.kr/icc_new/"+file_a_tag['href']
                        end
                         Attached.create(:link => file_url, :name => file_a_tag.text, :notice_id => Notice.last.id)
                    end
                    
                    #Image 정보, 저장 
                    images = notice_doc.css('td#content img')
                    images.each do |image|
                        if (image['src'] =~ /^http/)
                            img_url = image['src']
                        else
                            img_url = "http://icc.skku.ac.kr"+image['src']
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