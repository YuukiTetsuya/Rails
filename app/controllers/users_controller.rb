class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])                                              # paramsで:idパラメータを受け取る(/users/1にアクセスしたら1を受け取る)
  end
  
  def new
    @user = User.new                                                            # Userオブジェクトを作成
  end
  
  def create
    @user = User.new(user_params)                                               # newビューにて送ったformの中身(nameやemailの値)をuser_paramsで受け取り、ユーザーオブジェクトを生成、@userに代入
    if @user.save
      log_in @user                                                              # log_inメソッド(ログイン)の引数として@user(ユーザーオブジェクト)を渡す。要はセッションに渡すってこと
      flash[:success] = "ようこそYUUKIのサイトへ"                               # flashの:successシンボルに成功時のメッセージを代入
      redirect_to @user                                                         #(user_url(@user)　つまり/users/idへ飛ばす(https://qiita.com/Kawanji01/items/96fff507ed2f75403ecb)を参考
    else
      render 'new'
    end
  end
  
  
  private                                                                       # 外部から使えない（Usersコントローラ内のみ）部分
  
    def user_params                                                             # paramsハッシュの中を指定する。（requireで:user属性を必須、permitで各属性の値が入ってないとparamsで受け取れないよう指定）
      params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
    end
end
