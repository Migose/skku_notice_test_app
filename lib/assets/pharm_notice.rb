require 'nokogiri'
require 'net/http'
require 'active_support/all'
require 'uri'


list_uri = URI("http://pharm.skku.edu/board/board.jsp")
(1..1).each do |page|
        list_req = Net::HTTP.post_form(
        list_uri,
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
    links = list_doc.css('tr a')
    links.each do |link|
        link['href'].split('goView(')
    end
end