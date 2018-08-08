
#그룹 생성
Group.create(:name => '전체공지')       #1
Group.create(:name => '유학대학')       #2
Group.create(:name => '문과대학')       #3
Group.create(:name => '사회과학대학')   #4
Group.create(:name => '경제대학')       #5
Group.create(:name => '사범대학')       #6
Group.create(:name => '예술대학')       #7
Group.create(:name => '자연과학대학')   #8
Group.create(:name => '공과대학')       #9
Group.create(:name => '생명공학대학')   #10
Group.create(:name => '스포츠과학대학') #11
Group.create(:name => '성균융합원')     #12
Group.create(:name => '정보통신대학')   #13
Group.create(:name => '의과대학')       #14
Group.create(:name => '소프트웨어대학') #15
Group.create(:name => '약학대학')       #16
Group.create(:name => '경영대학')       #17

#초기데이터
(0...10).step(10).each do |offset|
    notice_list = "https://www.skku.edu/skku/campus/skk_comm/notice01.do?mode=list&&articleLimit=10&article.offset=#{offset}"
    #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 doc변수에 저장한다.
    doc = Nokogiri::HTML(open(notice_list))
    
    #.css selector로 공지의 href주소를 가져온다.
    links = doc.css('tbody tr td.left a')
    links.reverse.each do |link|
        notice_url = link['href']
        notice_link = "https://www.skku.edu/skku/campus/skk_comm/notice01.do"+notice_url
        notice_doc = Nokogiri::HTML(open(notice_link))
        
        #Notice 정보
        title = notice_doc.css('em.ellipsis').text
        writer = notice_doc.css('li.noline').text
        date = notice_doc.css('span.date').text.to_datetime
        content = notice_doc.css('pre.pre')

        #Notice 저장
        Notice.create(
            :link => notice_link,
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
def college_crawling_seed(group_id, url)
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
colleges.each do |college|
    college_crawling_seed(college[0],college[1])
end
(1..1).each do |page|
    list_doc = Nokogiri::HTML(open("https://biz.skku.edu/kr/boardList.do?bbsId=BBSMSTR_000000000001&pageIndex=#{page}"))
    links = list_doc.css("strong a")
    links.reverse.each do |link|
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
(1..1).each do |page|
    list_url ="http://icc.skku.ac.kr/icc_new/board_list_square?listPage=#{page}&boardName=board_notice&field=subject&keyword="
    #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 doc변수에 저장한다.
    list_doc = Nokogiri::HTML(open(list_url))
    #.css selector로 a태그들을 XML::Nodeset 형태로 가져와 href만 배열에 저장한다.
    a_tags = list_doc.css("td.board-title a")
    
    a_tags.reverse.each do |a_tag|
        notice_url = "http://icc.skku.ac.kr/icc_new/"+a_tag['href']
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
    end
end
(1..1).each do |page|
    list_url = "http://www.skkumed.ac.kr/notice.asp?keyword=&startpage=1&bcode=nt&pg=#{page}"
    #nokogiri parser로 HTML 형태로 분류한 형태의 데이터를 list_doc변수에 저장한다.
    list_doc = Nokogiri::HTML(open(list_url))
    
    #.css selector로 공지의 href주소를 가져온다.
    a_tags = list_doc.css('td.sub_text a:nth-of-type(1)')
    
    a_tags.reverse.each do |a_tag|
        href = a_tag['href']
        notice_url ="http://www.skkumed.ac.kr/"+href 
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
    end
end
(1..1).each do |page|
    list_req = Net::HTTP.post_form(
        URI("http://pharm.skku.edu/board/board.jsp"),
        {
        "catg"=> "notice",
        "pageCnt"=> "10",
        "totalPage"=> "159",
        # "totalPage"=> "1",
        # "totalPage"=> "10",
        "curPage"=> "#{}",
        "pagePerCnt"=> "10",
        "srch_catg"=> "news_title",
        "srch_word"=> ""
        }
    )
    list_doc = Nokogiri::HTML(list_req.body)
    a_tags = list_doc.css('tr a')
    a_tags.reverse.each do |a_tag|
        id = a_tag['href'].scan(/\d+/).first
        notice_url = "http://pharm.skku.edu/board/view.jsp?curNum=#{id}"
        notice_doc = Nokogiri::HTML(open(notice_url))
        title = notice_doc.css('tr th').text
        writer = notice_doc.css("td.spoqa").text.scan(/｜(.+)날짜/).first.first
        date = notice_doc.css("td.spoqa").text.scan(/날짜｜(.+)조회수/).first.first.to_datetime
        view = notice_doc.css("td.spoqa").text.scan(/조회수｜(.+)/).first.first
        content = notice_doc.css('div#contents')
        
        Notice.create(
            :link => notice_url,
            :title => title,
            :writer => writer,
            :date => date,
            :content => content,
            :view => view,
            :scrap_count => 0, #TODO: 물어보기
            :group_id => 16
            )
            
        files_a_tags = notice_doc.css('tr:nth-of-type(3) > td > a')
        files_a_tags.each do |file_a_tag|
            if (file_a_tag['href'] =~ /^http/)
                file_url = file_a_tag['href']
            else
                file_url = "http://pharm.skku.edu/board/"+file_a_tag['href']
            end
             Attached.create(:link => file_url, :name => file_a_tag.text, :notice_id => Notice.last.id)
        end
        
        images = notice_doc.css('div#contents img')
        images.each do |image|
            if (image['src'] =~ /^http/)
                img_link = image['src']
            else
                img_link = "http://pharm.skku.edu"+image['src']
            end
            Image.create(:link => img_link, :notice_id => Notice.last.id)
        end
    end
end
list_req = Net::HTTP.post_form(
    URI("http://cs.skku.edu/ajax/board/list/notice"),
    {
    "Accept"=> "*/*",
    "Accept-Encoding"=> ["gzip", "deflate"],
    "Accept-Language"=> ["ko-KR","ko;q=0.9","en-US;q=0.8","en;q=0.7","de;q=0.6","es;q=0.5"],
    "Connection"=> "keep-alive",
    "Content-Length"=>"0",
    "Cookie"=> "_ga=GA1.2.369078695.1522732267; _gid=GA1.2.1693306267.1533285169; HOMEPAGE_JSESSIONID=3UMDdt7oLHDgx9bRgtvpxE1ZxGCCiCV6J_TjkDcD5Abs52YpRq6S!1654620447; connect.sid=s%3AW34AiV51KYOveU4fswQSXOs2RPjVPFWg.eGAczyhR0%2FlT0%2FoeisI91w9Vv4DysuKLFCsemFaFUfw; _gat=1",
    "Host"=> "cs.skku.edu",
    "Origin"=> "http://cs.skku.edu",
    "Referer"=> "http://cs.skku.edu/open/notice/list",
    "User-Agent"=> "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    "X-Requested-With"=> "XMLHttpRequest"
    }
)
req_json = JSON.parse(list_req.body)
req_json['aaData'].take(10).reverse.each do |notice|
    id = notice['id']
    notice_uri = URI("http://cs.skku.edu/ajax/board/view/notice/#{id}")
    notice_req = Net::HTTP.post_form(
        notice_uri,
        {
        "Accept"=> "*/*",
        "Accept-Encoding"=> ["gzip", "deflate"],
        "Accept-Language"=> ["ko-KR","ko;q=0.9","en-US;q=0.8","en;q=0.7","de;q=0.6","es;q=0.5"],
        "Connection"=> "keep-alive",
        "Content-Length"=>"0",
        "Cookie"=> "_ga=GA1.2.369078695.1522732267; _gid=GA1.2.1693306267.1533285169; HOMEPAGE_JSESSIONID=3UMDdt7oLHDgx9bRgtvpxE1ZxGCCiCV6J_TjkDcD5Abs52YpRq6S!1654620447; connect.sid=s%3AW34AiV51KYOveU4fswQSXOs2RPjVPFWg.eGAczyhR0%2FlT0%2FoeisI91w9Vv4DysuKLFCsemFaFUfw; _gat=1",
        "Host"=> "cs.skku.edu",
        "Origin"=> "http://cs.skku.edu",
        "Referer"=> "http://cs.skku.edu/open/notice/view/2359",
        "User-Agent"=> "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
        "X-Requested-With"=> "XMLHttpRequest"
        }
    )
    notice_json = JSON.parse(notice_req.body)
    
    title = notice_json['post']['title']
    content = notice_json['post']['text']
    view = notice_json['post']['views']
    writer = notice_json['post']['name']
    date = notice_json['post']['time']
    notice_link = "http://cs.skku.edu/open/notice/view/#{id}"
    Notice.create(
            :title => title,
            :writer => writer,
            :date => date,
            :content => content,
            :view => view,
            :link => notice_link,
            :scrap_count => 0, #TODO: 물어보기
            :group_id => 15
            )
    
    notice_json['post']['files'].each do |file|
        if (file['link'] =~ /^http/)
            file_link = file['link']
        else
            file_link = "http://cs.skku.edu"+file['link']
        end
         Attached.create(:link => file_link, :name => file['name'], :notice_id => Notice.last.id)
    end
    
    image_doc = Nokogiri::HTML(notice_json['post']['text'])
    image_doc.css('img').each do |image|
        if (image['src'] =~ /^http/)
            img_url = image['src']
        else
            img_url = "http://cs.skku.edu"+image['src']
        end
        Image.create(:link => img_url, :notice_id => Notice.last.id)
    end
end