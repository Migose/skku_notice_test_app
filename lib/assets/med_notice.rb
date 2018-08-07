def med()
    puts '의과대학'
    (1..1).each do |page|
        notice_list = "http://www.skkumed.ac.kr/notice.asp?keyword=&startpage=1&bcode=nt&pg=#{page}"
        #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 doc변수에 저장한다.
        doc = Nokogiri::HTML(open(notice_list))
    
        #.css selector로 공지의 href주소를 가져온다.
        links = doc.css('td.sub_text a:nth-of-type(1)')
    
        links.each do |link|
            notice_url = link['href']
            notice_link ="http://www.skkumed.ac.kr/"+notice_url 
            notice_doc = Nokogiri::HTML(open(notice_link))
            #Notice 정보
            contents = notice_doc.css('td.sub_text')
            title = contents[0].text
            writer = contents[1].text
            view = contents[2].text
            date = notice_doc.css('div.sub_text').text.to_datetime #TODO: 오후/오전 구분
            content = contents[4]
    
            #Notice 저장
            Notice.create(
                :link => notice_link,
                :title => title,
                :writer => writer,
                :date => date,
                :content => content,
                :view => view,
                :scrap_count => 0, #TODO: 물어보기
                :group_id => 14
                )
            #Attached 정보, 저장
            files = notice_doc.css('td.sub_text > a')
            files.each do |file|
                if (file['href'] =~ /^http/)
                    file_link = file['href']
                else
                    puts "attachment's href doesn't start with 'http'"
                    next
                end
                 Attached.create(:link => file_link, :name => file.text, :notice_id => Notice.last.id)
            end
            
            #TODO: 이미지 추가? 
            images = notice_doc.css('td.sub_text img')
            images.each do |image|
                if (image['src'] =~ /^http/)
                    img_url = image['src']
                else
                    puts "image's src doesn't start with 'http'"
                    next
                end
                Image.create(:link => img_url, :notice_id => Notice.last.id)
            end
        end
    end
end