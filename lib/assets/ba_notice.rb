
def ba()
    puts '경영대학'
    (1..1).each do |page|
        list_url = "https://biz.skku.edu/kr/boardList.do?bbsId=BBSMSTR_000000000001&pageIndex=#{page}"
        list_doc = Nokogiri::HTML(open(list_url))
        new_notice_count = 0
        a_tags = list_doc.css("strong a")
        if "http://biz.skku.edu/kr/board.do?bbsId=BBSMSTR_000000000001&nttId="+a_tags.first['href'].scan(/\d+/).first != Notice.where(:group_id => 17).last.link
            puts "공지가 업데이트 되었습니다."
            a_tags.reverse.each do |a_tag|
                nttId = a_tag['href'].scan(/\d+/).first
                notice_url = "http://biz.skku.edu/kr/board.do?bbsId=BBSMSTR_000000000001&nttId=#{nttId}"
                if Notice.exists?(link: notice_url)
                    next
                else
                    notice_doc = Nokogiri::HTML(open(notice_url))
                    
                    title = notice_doc.css("div.view_title h2").text
                    writer = notice_doc.css('div.view_data').text.scan(/분류(\S+)\s/).first.first  #TODO: 카테고리인데 작성자로 해도 될지
                    date = notice_doc.css('div.view_data').text.scan(/(\d{4}-\d{2}-\d{2})/).first.first.to_datetime
                    view = notice_doc.css('div.view_data').text.scan(/조회(\d+)/).first.first
                    content = notice_doc.css('div.view_content')
                
                    Notice.create(
                                :title => title,
                                :writer => writer,
                                :date => date,
                                :content => content,
                                :view => view,
                                :scrap_count => 0,
                                :link => notice_url,
                                :group_id => 17
                                )
                
                
                    files_a_tags = notice_doc.css('div.view_file a')
                    files_a_tags.each do |file_a_tag|
                        if (file_a_tag['href'] =~ /^http/)
                            file_url = file_a_tag['href']
                        else
                            file_name = file_a_tag['href'].scan(/'(\S+?)'/).first.first
                            file_sn = file_a_tag['href'].scan(/'(\S+?)'/).last.first
                            file_url = "https://biz.skku.edu/cmm/fms/FileDown.do?atchFileId=#{file_name}&fileSn=#{file_sn}"
                        end
                         Attached.create(:link => file_url, :name => file.text, :notice_id => Notice.last.id)
                    end
                    
                    images = notice_doc.css('div.view_content img')
                    images.each do |image|
                        if (image['src'] =~ /^http/)
                            img_link = image['src']
                        else
                            img_link = "https://biz.skku.edu"+image['src']
                        end
                        Image.create(:link => img_link, :notice_id => Notice.last.id)
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