require 'nokogiri'
require 'open-uri'
require 'active_support/all'

(0...10).step(10).each do |offset|
    notice_list = "https://www.skku.edu/skku/campus/skk_comm/notice01.do?mode=list&&articleLimit=10&article.offset=#{offset}"
    #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 doc변수에 저장한다.
    doc = Nokogiri::HTML(open(notice_list))
    
    #.css selector로 공지의 href주소를 가져온다.
    links = doc.css('tbody tr td.left a')
    links.each do |link|
        notice_url = link['href']
        notice_doc = Nokogiri::HTML(open("https://www.skku.edu/skku/campus/skk_comm/notice01.do"+notice_url))
        
        #Notice 정보
        title = notice_doc.css('em.ellipsis').text
        writer = notice_doc.css('li.noline').text
        date = notice_doc.css('span.date').text.to_datetime
        content = notice_doc.css('pre.pre')

        #Notice 저장
        Notice.create(
            :title => title,
            :writer => writer,
            :date => date,
            :content => content,
            :view => 100, #TODO: 고치기
            :scrap_count => 0, #TODO: 물어보기
            :group_id => 1
            )
            
        #Attached 정보, 저장
        files = notice_doc.css('ul.filedown_list > li > a.ellipsis')
        files.each do |file|
            if (file['href'] =~ /^http/)
                file_link = file['href']
            else
                file_link = "https://www.skku.edu/skku/campus/skk_comm/notice01.do"+file['href']
            end
             Attached.create(:link => file_link, :name => file.text, :notice_id => Notice.last.id)
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
    end
end