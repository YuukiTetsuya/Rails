class User < ApplicationRecord
  
  before_save { email.downcase! }                                               #DB保存前にemailの値を小文字に変換する
  validates :name, presence: true, length: { maximum: 50 }                      #nameの文字列が空でなく、50文字以下ならtrue
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i                      #正規表現でemailのフォーマットを策定し、定数に代入
  validates :email, presence: true, length: { maximum: 255 },                   #emailの文字列が空でなく、255文字以下ならtrue
                    format: { with: VALID_EMAIL_REGEX },                        #emailのフォーマットを引数に取ってフォーマット通りか検証する。
                    uniqueness: { case_sensitive: false }                       #大文字小文字を区別しない(false)に設定する　このオプションでは通常のuniquenessはtrueと判断する。
  
  has_secure_password                                                           #passwordとpassword_confirmation属性に存在性と値が一致するかどうかの検証が追加される
  validates :password, presence: true,length: { minimum: 6 }                    #passwordの文字列が空でなく、6文字以上ならtrue

  #fixture用に、password_digestの文字列をハッシュ化して、ハッシュ値として返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
