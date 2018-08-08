def college_crawling(group_id, list_url)
    puts Group.find(group_id).name

    college_url = list_url.split('?')[0]
    download_url = list_url.split('.edu')[0]+'.edu'
    
    (0...10).step(10).each do |offset|

        #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 list_doc변수에 저장한다.
        list_doc = Nokogiri::HTML(open(list_url+offset.to_s))
        new_notice_count = 0

        #.css selector로 a태그들을 XML::Nodeset 형태로 가져와 href만 배열에 저장한다.
        hrefs = []
        (1..10).each do |x|
            notice_href = list_doc.css("tbody tr:nth-last-of-type(#{x}) a")[0]['href']
            hrefs.push(notice_href)
        end
        if (college_url+hrefs.last) != Notice.where(:group_id => group_id).last.link
            puts "공지가 업데이트 되었습니다."
        
            hrefs.each do |href|
                if Notice.exists?(link: college_url+href)
                    next
                else
                    notice_doc = Nokogiri::HTML(open(college_url+href))
        
                    #Notice 정보
                    table_list = notice_doc.css('td.td')
                    title = table_list[0].text
                    writer = table_list[1].text
                    date = table_list[2].text
                    view = table_list[3].text
                    content = notice_doc.css('div#article_text')
                    notice_link = college_url+href
                    
                    
                    #Notice 저장
                    Notice.create!(
                        :title => title,
                        :writer => writer,
                        :date => date,
                        :content => content,
                        :view => view,
                        :scrap_count => 0, #TODO: 물어보기
                        :group_id => group_id,
                        :link => notice_link
                        #:keyword_id => 1, #TODO: ??
                        #:user_id => 1 #TODO: ??
                        )
                        
                    #Attached 정보, 저장
                    files_a_tags = notice_doc.css('ul.attach_list li a')
                    files_a_tags.each do |file_a_tag|
                        if (file_a_tag['href'] =~ /^http/)
                            file_url = file_a_tag['href']
                        else
                            file_url = download_url+file_a_tag['href']
                        end
                         Attached.create(:link => file_url, :name => file_a_tag.text, :notice_id => Notice.last.id)
                    end
                    
                    #Image 정보, 저장 
                    images = notice_doc.css('div#article_text img')
                    images.each do |image|
                        if (image['src'] =~ /^http/)
                            img_url = image['src']
                        else
                            img_url = download_url+image['src']
                        end
                        Image.create(:link => img_url, :notice_id => Notice.last.id)
                    end
                    new_notice_count +=1
                end
            end
            puts("#{new_notice_count}건의 공지가 동기화 되었습니다.")
        else
            puts("공지가 최신입니다.")
        end
    end
end