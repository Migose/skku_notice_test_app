def icc()
    puts'정보통신대학'
    (1..1).each do |page|
        #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 doc변수에 저장한다.
        doc = Nokogiri::HTML(open("http://icc.skku.ac.kr/icc_new/board_list_square?listPage=#{page}&boardName=board_notice&field=subject&keyword="))
    
        #.css selector로 a태그들을 XML::Nodeset 형태로 가져와 href만 배열에 저장한다.
        links = doc.css("td.board-title a")
        
        links.each do |link|
            notice_url = "http://icc.skku.ac.kr/icc_new/"+link['href']
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
            files = notice_doc.css('td.attachment a')
            files.each do |file|
                if (file['href'] =~ /^http/)
                    file_link = file['href']
                else
                    file_link = "http://icc.skku.ac.kr/icc_new/"+file['href']
                end
                 Attached.create(:link => file_link, :name => file.text, :notice_id => Notice.last.id)
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
        end
    end
end