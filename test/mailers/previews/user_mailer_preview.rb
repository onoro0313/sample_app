# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
# メールプレビューという裏技、railsでは特殊なurlにアクセスするとメールのメッセージをその場でプレビューすることができ便利

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    # Usersテーブルの最初のuserを代入account_activationメソッドに引数として持たせる
    user.activation_token = User.new_token
    # htmlやtextのテンプレートでアカウント有効化トークンが必要なので代入をする。
    UserMailer.account_activation(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    UserMailer.password_reset
  end

end
