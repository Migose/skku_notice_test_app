#TODO: 경영대학 홈페이지 바뀜?
# require 'nokogiri'
# require 'net/http'
# require 'active_support/all'
# require 'uri'

# list_uri = URI("https://biz.skku.edu/kr/boardList.do")
# notice_uri = URI("https://biz.skku.edu/kr/board.do")
# puts '1'
# (1..2).each do |page|
#     puts '2'
#     list_req = Net::HTTP.post_form(list_uri,{
#         "bbsId"=> "BBSMSTR_000000000001",
#         "nttId" => "0",
#         "bbsTyCode" => "BBST01",
#         "bbsAttrbCode" => "BBSA03",
#         "authFlag=" =>"" ,
#         "noticeCategory" => "",
#         "pageIndex" => "#{page}",
#         "searchCnd" => "0",
#         "searchWrd" => ""}
#     )
#     list_doc = Nokogiri::HTML(list_req.body)
#     links = list_doc.css("strong a")
#     links.each do |link|
#         nttId = link['href'].split('')[1]
#         notice_doc = Nokogiri::HTML(Net::HTTP.post_form(notice_uri,
#                                 {
#                                 "bbsId"=> "BBSMSTR_000000000001",
#                                 "nttId" => nttId,
#                                 "bbsTyCode" => "BBST01",
#                                 "bbsAttrbCode" => "BBSA03",
#                                 "authFlag=" =>"" ,
#                                 "noticeCategory" => "",
#                                 "pageIndex" => "#{page}",
#                                 "searchCnd" => "0",
#                                 "searchWrd" => ""
#                                 }
#                             ).body)
#       puts notice_doc.css("div.view_title")
#   end
# end