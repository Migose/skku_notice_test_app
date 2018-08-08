def med()
    puts '의과대학'
    (1..1).each do |page|
        list_url = "http://www.skkumed.ac.kr/notice.asp?keyword=&startpage=1&bcode=nt&pg=#{page}"
        #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 list_doc변수에 저장한다.
        list_doc = Nokogiri::HTML(open(list_url))
        new_notice_count = 0
        #.css selector로 공지의 href주소를 가져온다.
        a_tags = list_doc.css('td.sub_text a:nth-of-type(1)')
        if ("http://www.skkumed.ac.kr/"+a_tags.first['href']) != Notice.where(:group_id => 14).last.link
            puts "공지가 업데이트 되었습니다."
            a_tags.reverse.each do |a_tag|
                notice_href = a_tag['href']
                notice_url ="http://www.skkumed.ac.kr/"+notice_href 
                if Notice.exists?(link: notice_url)
                    next
                else
                    notice_doc = Nokogiri::HTML(open(notice_url))
                    #Notice 정보
                    contents = notice_doc.css('td.sub_text')
                    title = contents[0].text
                    writer = contents[1].text
                    view = contents[2].text
                    date = notice_doc.css('div.sub_text').text.to_datetime #TODO: 오후/오전 구분
                    content = contents[4]
            
                    #Notice 저장
                    Notice.create(
                        :link => notice_url,
                        :title => title,
                        :writer => writer,
                        :date => date,
                        :content => content,
                        :view => view,
                        :scrap_count => 0, #TODO: 물어보기
                        :group_id => 14
                        )
                    #Attached 정보, 저장
                    files_a_tags = notice_doc.css('td.sub_text > a')
                    files_a_tags.each do |file_a_tag|
                        if (file_a_tag['href'] =~ /^http/)
                            file_url = file_a_tag['href']
                        else
                            puts "attachment's href doesn't start with 'http'"
                            next
                        end
                         Attached.create(:link => file_url, :name => file_a_tag.text, :notice_id => Notice.last.id)
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
                    new_notice_count += 1
                end
            end
            puts("#{new_notice_count}건의 공지가 동기화 되었습니다.")
        else
            puts("공지가 최신입니다.")
        end
    end
end