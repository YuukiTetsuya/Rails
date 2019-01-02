require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do                                                      # newアクション(/login)に対してのテスト
    get login_path                                                              # /loginにgetリクエストを送る（取得）
    assert_response :success                                                    # レスポンスが成功したらtrue、失敗ならfalse
  end

end
