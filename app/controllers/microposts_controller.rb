class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]                      # ログインユーザーのみ作成したり削除できるよう適用
  before_action :correct_user,   only: :destroy
  
  def create
    @micropost = current_user.microposts.build(micropost_params)                # formで送った値をmicropost_paramsで受け取り、親モデルと関連付け(bulid)してcurrent_userに渡して代入
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end
  
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_back(fallback_location: root_url)                                  # 前回開いていたページ、なければroot_urlへリダイレクト
  end
  
  private
  
    def micropost_params
      params.require(:micropost).permit(:content, :picture)                     # pictureとcontentをmicropostハッシュの許可された属性のリストに追加する
    end
    
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end