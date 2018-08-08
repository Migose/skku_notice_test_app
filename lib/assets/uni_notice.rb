require 'nokogiri'
require 'net/http'
require 'active_support/all'
require 'uri'
require 'open-uri'


require './lib/assets/college_notice_type1'
require './lib/assets/cs_notice'
require './lib/assets/icc_notice'
require './lib/assets/main_notice'
require './lib/assets/med_notice'
require './lib/assets/pharm_notice'
require './lib/assets/ba_notice'

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

while true do
    colleges.each do |college|
    college_crawling(college[0],college[1])
    end
    
    cs()
    icc()
    main_notice()
    med()
    pharm()
    ba()
    
    puts 'Sleep'
    sleep(5.minutes)
end