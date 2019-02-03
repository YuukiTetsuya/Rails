class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper                                                        #SessionHelper(メソッドの集合体)を全コントローラに適用
  
  private
  
    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?                                                         # ログインしていなければ処理を実行
       store_location                                                           # 前にアクセスしたページを記憶
       flash[:danger] = "Please log in."
       redirect_to login_url
      end
    end
end
