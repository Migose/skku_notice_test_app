def college_crawling(group_id, url)
    puts Group.find(group_id).name

    notice_url = url.split('?')[0]
    download_url = url.split('.edu')[0]+'.edu'
    
    (0...10).step(10).each do |offset|

        #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 doc변수에 저장한다.
        doc = Nokogiri::HTML(open(url+offset.to_s))

        #.css selector로 a태그들을 XML::Nodeset 형태로 가져와 href만 배열에 저장한다.
        links = []
        (1..10).each do |x|
            notice_href = doc.css("tbody tr:nth-last-of-type(#{x}) a")[0]['href']
            links.push(notice_href)
        end
        
        links.each do |link|
            notice_doc = Nokogiri::HTML(open(notice_url+link))

            #Notice 정보
            table_list = notice_doc.css('td.td')
            title = table_list[0].text
            writer = table_list[1].text
            date = table_list[2].text
            view = table_list[3].text
            content = notice_doc.css('div#article_text')
            notice_link = notice_url+link
            
            
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
            files = notice_doc.css('ul.attach_list li a')
            files.each do |file|
                if (file['href'] =~ /^http/)
                    file_link = file['href']
                else
                    file_link = download_url+file['href']
                end
                 Attached.create(:link => file_link, :name => file.text, :notice_id => Notice.last.id)
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
        end
    end
end