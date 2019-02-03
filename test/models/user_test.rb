require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")       # Userモデルにnameとemailとpasswordとpassword確認用の値を引数に取ったレコードを生成。
  end
  
  test "should be valid" do
    assert @user.valid?                                                         # @user.valid?がtrueを返すと成功、falseを返すと失敗
  end

  
  test "name should be present" do
    @user.name = "      "
    assert_not @user.valid?                                                     # @userが有効でなくなったことを確認（@userが無効なら成功、有効なら失敗）
  end
  
  test "email bhould be present" do
    @user.email = "     "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51                                                       # 51文字の"a"を@user.nameに代入
    assert_not @user.valid?                                                     # @userが有効でなくなった（nameが50文字より多い）ことを確認(@userが無効なら成功、有効なら失敗)
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"                                    # 244文字の"a"と"@example.com"を足し合わせた文字を@user.emailに代入
    assert_not @user.valid?                                                     # @userが有効でなくなった（emailが255文字より多い）か確認(@userが無効なら成功、有効なら失敗)
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.   
                           foo@bar_baz.com foo@bar+baz.com]                     # 配列で５つのアドレス指定
    invalid_addresses.each do |invalid_address|                                 # それぞれの要素をブロックinvalid_addressに繰り返し代入。1つずつ検証。
    @user.email = invalid_address                                               # @user.emailにブロックを代入
    assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"     # @userが有効なら失敗、無効なら成功。第二引数で失敗したメールアドレスをそのまま文字列として表示
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup                                                  # @userを複製する
    duplicate_user.email = @user.email.upcase                                   # 複製したduplicate_userのメールアドレス欄の文字列を大文字にする
    @user.save                                                                  # @userをデータベースに保存
    assert_not duplicate_user.valid?                                            # @userの複製が有効なら失敗、無効なら成功
  end
  
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.Com"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email                  # 第一引数で@userのEmailを小文字に変換、第二引数でDBからEmail(大文字小文字混同のemail)を再読み込み、この二つが同一であればtrueを返す
  end
  
  test "password should be present (nonblank)" do                               # passwordとpassword_confirmationが空かどうか検証
    @user.password = @user.password_confirmation = " " * 6                      # 二つの属性に空白文字を6個代入
    assert_not @user.valid?                                                     # @userが有効なら失敗、無効なら成功
  end
  
  test "password should have a minimum length" do                               # passwordとpassword_confirmationが最低6文字以上あるかどうか検証
    @user.password = @user.password_confirmation = "a" * 5                      # 二つの属性に"a"を5個代入
    assert_not @user.valid?                                                     # @userが有効なら失敗、無効なら成功
  end
  
  test "authenticated? should return false for a user with nil digest" do       # authenticatedメソッドで記憶ダイジェストを暗号化できるか検証
    assert_not @user.authenticated?(:remember, '')                              # @userのユーザーの記憶ダイジェストと、引数で受け取った値が同一ならfalse、異なるならtrueを返す
  end
  
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end
