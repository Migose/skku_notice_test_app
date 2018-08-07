
def ba()
    puts '경영대학'
    (1..1).each do |page|

        list_doc = Nokogiri::HTML(open("https://biz.skku.edu/kr/boardList.do?bbsId=BBSMSTR_000000000001&pageIndex=#{page}"))
        links = list_doc.css("strong a")
        links.each do |link|
            nttId = link['href'].scan(/\d+/).first
            notice_url = "http://biz.skku.edu/kr/board.do?bbsId=BBSMSTR_000000000001&nttId=#{nttId}"
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
        
        
            files = notice_doc.css('div.view_file a')
            files.each do |file|
                if (file['href'] =~ /^http/)
                    file_link = file['href']
                else
                    file_name = file['href'].scan(/'(\S+?)'/).first.first
                    file_sn = file['href'].scan(/'(\S+?)'/).last.first
                    file_link = "https://biz.skku.edu/cmm/fms/FileDown.do?atchFileId=#{file_name}&fileSn=#{file_sn}"
                end
                 Attached.create(:link => file_link, :name => file.text, :notice_id => Notice.last.id)
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
        end
    end
end