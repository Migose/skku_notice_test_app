require 'test_helper'

class NoticeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get notice_index_url
    assert_response :success
  end

  test "should get show" do
    get notice_show_url
    assert_response :success
  end

  test "should get images" do
    get notice_images_url
    assert_response :success
  end

  test "should get attacheds" do
    get notice_attacheds_url
    assert_response :success
  end

end
