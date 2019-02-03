class StaticPagesController < ApplicationController
  
  def home
    if logged_in?
      @micropost  = current_user.microposts.build                               # current_userに紐付いたマイクロポストオブジェクトを生成し代入
      @feed_items = current_user.feed.paginate(page: params[:page])             # current_userに紐付いたポストをページネーション化して代入
    end
  end
  
  def help
  end
  
  def about
  end
  
  def contact
  end
  
end
