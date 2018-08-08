크롤링 테스트 용입니다.
============
더미 데이터
-----
더미데이터를 생성하기 위해선 다음 절차를 따라주세요

1.마이그레이션을 해주세요

    rails db:migrate
2.더미데이터로 각 단과대학 1페이지 공지(10개 의과대학은 20개)를 불러옵니다.

    rails db:seed
3.5분마다 업데이트를 하는 파일은 uni_notice.rb입니다.

    rails r lib/assets/uni_notice.rb

뷰파일
-----
뷰파일은 다음과 같이 있습니다.

index, show, images, attacheds

index는 루트로 돼있어서 바로 볼 수 있습니다.

show는 해당하는 글을 누르면 갑니다.

images는 /notices/images 로 가면 이미지의 url과 연결된 id가 나옵니다.

attacheds는 /notices/attacheds 로 가면 파일의 url과 이름이 나옵니다.
