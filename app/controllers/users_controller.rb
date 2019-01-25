class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]       # logged_in_userメソッドを適用
  before_action :correct_user,   only: [:edit, :update]                         # editとupdateアクションにcorret_userメソッドを適用
  before_action :admin_user,     only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])          # Userを取り出して分割した値を@usersに代入
  end

  def show
    @user = User.find(params[:id])                                              # paramsで:idパラメータを受け取る(/users/1にアクセスしたら1を受け取る)
    redirect_to root_url and return unless @user.activated?                     # activatedがfalseならルートURLヘリダイレクト
  end
  
  def new
    @user = User.new                                                            # Userオブジェクトを作成
  end
  
  def create
    @user = User.new(user_params)                                               # newビューにて送ったformの中身(nameやemailの値)をuser_paramsで受け取り、ユーザーオブジェクトを生成、@userに代入
    if @user.save
      @user.send_activation_email                                               # アカウント有効化メールの送信
      flash[:info] = "メールを確認してアカウントを有効化してね"                 # アカウント有効化メッセージの表示
      redirect_to root_url                                                      # ホームへ飛ばす
    else
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィール更新完了"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "削除完了"
    redirect_to users_url
  end
  
  private                                                                       # 外部から使えない（Usersコントローラ内のみ）部分
  
    def user_params                                                             # paramsハッシュの中を指定する。（requireで:user属性を必須、permitで各属性の値が入ってないとparamsで受け取れないよう指定）
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end
    
    # beforeアクション
    
    # ログイン済みユーザーかどうか確認
    def logged_in_user                                                          # ログイン済みユーザーかどうか確認
      unless logged_in?                                                         # ユーザーがログインしていなければ(false)処理を行う
        store_location                                                          # アクセスしようとしたURLを覚えておく
        flash[:danger] = "ログインしないとダメですよ"                           # エラーメッセージを書く
        redirect_to login_url                                                   # ログインユーザーのidを引数に取ったURLのページへ飛ぶ
      end
    end
    
    def correct_user                                                            # 正しいユーザーかどうか確認
      @user = User.find(params[:id])                                            # URLのidの値と同じユーザーを@userに代入
      redirect_to(root_url) unless current_user?(@user)                         # @userと記憶トークンcookieに対応するユーザー(current_user)を比較して、失敗したらroot_urlへリダイレクト
    end
    
    def admin_user                                                              # 管理者のみに適用
      redirect_to(root_url) unless current_user.admin?                          # 現在のユーザーが管理者でなければroot_urlへリダイレクト
    end
end
