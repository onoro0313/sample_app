class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  # ブラウザ間のemail入力の大文字小文字の仕様解消
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},format: { with: VALID_EMAIL_REGEX },uniqueness: { case_sensitive: false }
  has_secure_password
  # password_digestカラム #string が必要
  # bcrypt gem も同時に必要
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

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
  def authenticated?(attribute,token)
    digest = self.send("#{attribute}_digest")
    # この場合digestの中身はsendによってレシーバーに対してattributeの中身によって変動する???_digestが渡され、返り値を得る。
    return false if digest.nil?
    # 渡されたトークンがnilだった場合authenticated?をfalseにする。assert_notに対応。greenでテスト通る
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する。logout機能
  def forget
    update_attribute(:remember_digest, nil)
  end
  # アカウントを有効にする
  def activate
    update_attribute(:activated, true)
      # ユーザーを認証する
    update_attribute(:activated_at, Time.zone.now)
      # タイムスタンプの更新
  end
  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end
  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
    # 少ないとして捉えるな。早いとして捉える。「パスワード再設定メールの送信時刻が現在時刻より2時間以上早いの場合」
  end
  private
  # メールアドレスを全て小文字にする
  def downcase_email
    self.email.downcase!
  end
  # 有効化トークンとダイジェストを作成及び代入する
  def create_activation_digest
    self.activation_token = User.new_token
    # トークン作成
    self.activation_digest = User.digest(activation_token)
    # ハッシュ化
  end
end
