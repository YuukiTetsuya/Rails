class User < ApplicationRecord
  # 関連付け
  has_many :microposts, dependent: :destroy
  # インスタンス変数の定義
  attr_accessor :remember_token , :activation_token, :reset_token               # 記憶トークン、有効化トークン、レセットトークンを定義
  before_save   :downcase_email                                                 # DB保存前にemailの値を小文字に変換する
  before_create :create_activation_digest                                       # 作成前に適用
  validates :name, presence: true, length: { maximum: 50 }                      # nameの文字列が空でなく、50文字以下ならtrue
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i                      # 正規表現でemailのフォーマットを策定し、定数に代入
  validates :email, presence: true, length: { maximum: 255 },                   # emailの文字列が空でなく、255文字以下ならtrue
                    format: { with: VALID_EMAIL_REGEX },                        # emailのフォーマットを引数に取ってフォーマット通りか検証する。
                    uniqueness: { case_sensitive: false }                       # 大文字小文字を区別しない(false)に設定する　このオプションでは通常のuniquenessはtrueと判断する。
  
  has_secure_password                                                           # passwordとpassword_confirmation属性に存在性と値が一致するかどうかの検証が追加される
  validates :password, presence: true,length: { minimum: 6 }, allow_nil: true   # passwordの文字列が空でなく、6文字以上ならtrue。例外処理に空(nil)の場合のみバリデーションを通す(true)
  
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
  
  # トークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)                                     # DBにある記憶ダイジェストをnilにする
  end
  
  # アカウントを有効にする
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end
  
  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now )
  end
  
  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  # 試作feedの定義
  # 完全な実装はユーザーをフォローするで行う
  def feed
    Micropost.where("user_id = ?", id)
  end
  
private

  # メールアドレスを全て小文字にする

  def downcase_email
    self.email = email.downcase                                                 # emailを小文字化してUserオブジェクトのemail属性に代入
  end
  
  # 有効化トークンとダイジェストを作成および代入する
    
  def create_activation_digest
    self.activation_token   =   User.new_token                                  # ハッシュ化した記憶トークンを有効化トークン属性に代入
    self.activation_digest  =   User.digest(activation_token)                   # 有効化トークンをBcryptで暗号化し、有効化ダイジェスト属性に代入
  end
end