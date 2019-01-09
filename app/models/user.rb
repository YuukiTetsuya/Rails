class User < ApplicationRecord
  # インスタンス変数の定義
  attr_accessor :remember_token
  
  
  before_save { email.downcase! }                                               #DB保存前にemailの値を小文字に変換する
  validates :name, presence: true, length: { maximum: 50 }                      #nameの文字列が空でなく、50文字以下ならtrue
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i                      #正規表現でemailのフォーマットを策定し、定数に代入
  validates :email, presence: true, length: { maximum: 255 },                   #emailの文字列が空でなく、255文字以下ならtrue
                    format: { with: VALID_EMAIL_REGEX },                        #emailのフォーマットを引数に取ってフォーマット通りか検証する。
                    uniqueness: { case_sensitive: false }                       #大文字小文字を区別しない(false)に設定する　このオプションでは通常のuniquenessはtrueと判断する。
  
  has_secure_password                                                           #passwordとpassword_confirmation属性に存在性と値が一致するかどうかの検証が追加される
  validates :password, presence: true,length: { minimum: 6 }                    #passwordの文字列が空でなく、6文字以上ならtrue
  
  # Userクラスに対して定義する
  
  class << self
    
  # 渡された文字列のハッシュ値を返す
    
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :  # Userクラスにnew_tokenを渡したクラスメソッドを作成
                                                    BCrypt::Engine.cost         # SecureRandomモジュールにbase64でランダムな文字列を生成
      BCrypt::Password.create(string, cost: cost)
    end
    
    def new_token                                                               # 記憶トークンをremember_token属性に代入 
      SecureRandom.urlsafe_base64                                               # DBのremember_token属性値をBcryptに渡してハッシュ化して更新
    end
  end
  
  # 記憶トークンをUserオブジェクトのremember_token属性に代入し、DBに記憶ダイジェストとして保存
  def remember
    self.remember_token = User.new_token                                        # 記憶トークンをremember_token属性に代入 
    update_attribute(:remember_digest, User.digest(remember_token))             # DBのremember_token属性値をBcryptに渡してハッシュ化して更新
  end
  
  # 引数として受け取った値を記憶トークンに代入して暗号化（記憶ダイジェスト）し、DBにいるユーザーの記憶ダイジェストと比較、同一ならtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?                                        # 記憶ダイジェストがnilの場合、falseを戻り値として返す(処理の中断)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)          # DBの記憶ダイジェストと、受け取った記憶トークンを記憶ダイジェストにした値を比較
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)                                     # DBにある記憶ダイジェストをnilにする
  end
  
end