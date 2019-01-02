class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper                                                        #SessionHelper(メソッドの集合体)を全コントローラに適用
  
  def home
    render html: "こんにちは世界"
  end
end
