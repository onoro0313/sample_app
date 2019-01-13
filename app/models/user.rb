class User < ApplicationRecord
  before_save {email.downcase!}
  # ブラウザ間のemail入力の大文字小文字の仕様解消
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},format: { with: VALID_EMAIL_REGEX },uniqueness: { case_sensitive: false }
  has_secure_password
  # password_digestカラム #string が必要
  # bcrypt gem も同時に必要
  validates :password, presence: true, length: { minimum: 6 }

end
