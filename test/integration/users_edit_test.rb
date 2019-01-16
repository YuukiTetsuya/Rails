require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  test "unsuccessful edit" do                                                   
    log_in_as(@user)                                                            # ログインする
    get edit_user_path(@user)                                                   # ユーザー編集ページを取得する
    assert_template 'users/edit'                                                # 編集ページを描画する
    patch user_path(@user), params: { user: { name: "",                         # 編集する
                                              email: "foo@valid",
                                              password:               "foo",
                                              password_confirmation:  "bar" } }
    assert_template 'users/edit'                                                # 編集できたか確認
  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)                                                   # @userのユーザー編集ページを取得
    assert_equal session[:forwarding_url], edit_user_url(@user)                 # 渡されたURLに転送されているか確認
    log_in_as(@user)                                                            # @userでログイン
    assert_nil session[:forwarding_url]                                         # forwarding_urlの値がnilならtrue(deleteが効いてる)
    name  = "Foo Bar"                                                           # フォーム欄に値を入力する
    email = "foo@bar.com"                                                       
    patch user_path(@user), params: { user: { name: name,                       # 引数としてわざと失敗する値を持ったuserIDをpatchリクエストで送信（更新）する
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?                                                     # エラー文が空じゃなければtrue
    assert_redirected_to @user                                                  # michaelのユーザーidページへ移動できたらtrue
    @user.reload
    assert_equal name,  @user.name                                              # DB内の名前と@userの名前が一致していていたらtrue
    assert_equal email, @user.email                                             # DB内のEmailと@userの名前が一致
  end
end