require 'nokogiri'
require 'open-uri'
require 'active_support/all'

colleges = [
    [2,"http://scos.skku.edu/scos/menu_4/sub_04_01_01.jsp?mode=list&board_no=69&pager.offset="],
    [3,"http://liberalarts.skku.edu/liberal/menu_6/data_01.jsp?mode=list&board_no=229&pager.offset="],
    [4,"http://sscience.skku.edu/sscience/menu_4/sub4_1.jsp?mode=list&board_no=219&pager.offset="],
    [5,"http://ecostat.skku.edu/ecostat/menu_6/sub6_1.jsp?mode=list&board_no=304&pager.offset="],
    [6,"http://coe.skku.edu/coe/menu_2/sub_02_7_1.jsp?mode=list&board_no=136&pager.offset=" ],
    [7,"http://art.skku.edu/art/menu_4/sub4_1.jsp?mode=list&board_no=165&pager.offset="],
    [8,"http://cscience.skku.edu/cscience_kor/menu_5/sub5_3_2.jsp?mode=list&board_no=180&pager.offset="],
    [9,"http://shb.skku.edu/enc/menu_6/sub6_2.jsp?mode=list&board_no=1377&pager.offset="],
    [10,"http://biotech.skku.edu/biotech/menu4/sub4_1.jsp?mode=list&board_no=272&pager.offset="],
    [11,"http://sport.skku.edu/sports/menu_4/sub4_2.jsp?mode=list&board_no=827&pager.offset="],
    [12,"http://icon.skku.edu/icon/menu_5/sub5_1.jsp?mode=list&board_no=122&pager.offset="]
    ]
    
def college_crawling(group_id, url)
    puts Group.find(group_id).name
    puts group_id
    puts url
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
            puts title
            
            #Notice 저장
            Notice.create!(
                :title => title,
                :writer => writer,
                :date => date,
                :content => content,
                :view => view,
                :scrap_count => 0, #TODO: 물어보기
                :group_id => group_id
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

colleges.each do |college|
    college_crawling(college[0],college[1])
end