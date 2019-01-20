class User < ApplicationRecord
  attr_accessor :remember_token
  before_save {email.downcase!}
  # ブラウザ間のemail入力の大文字小文字の仕様解消
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},format: { with: VALID_EMAIL_REGEX },uniqueness: { case_sensitive: false }
  has_secure_password
  # password_digestカラム #string が必要
  # bcrypt gem も同時に必要
  validates :password, presence: true, length: { minimum: 6 }

# 渡された文字列のハッシュ値を返す。記憶トークンをハッシュ値へ変換しDBに保存する。
  def User.digest(string)
  cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    #記憶トークン作成用のメソッドUser.new_tokenにより、passwordがトークン化された時にかぶるものがなくなる
    SecureRandom.urlsafe_base64
  end
  def remember
    # ユーザーを記憶するためには、記憶トークンを作成して、そのトークンをダイジェストに変換したものをデータベースに保存する。User.digestメソッドにより、複雑な文字列をハッシュに変換。
    self.remember_token = User.new_token
    # remember_token
    #記憶トークンをユーザーと関連付け、トークンに対応する記憶ダイジェストをデータベースに保存する。user.remember_tokenメソッド (cookiesの保存場所です) を使ってトークンにアクセスできるようにする
    update_attribute(:remember_digest,User.digest(remember_token))
    # update_attribute 属性のハッシュを受け取り、成功時には更新と保存を続けて同時に行う。
  end
   # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    # 渡されたトークンがnilだった場合authenticated?をfalseにする。assert_notに対応。greenでテスト通る
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する。logout機能
  def forget
    update_attribute(:remember_digest, nil)
  end

end
