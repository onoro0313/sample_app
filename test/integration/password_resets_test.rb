require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
# ・forgot_passwordフォームの表示
# ・無効なアドレスを送信
# 有効なメールアドレスの送信→パスワード再設定用トークンが作成→再設定用メールが送信→メールのリンクを開いて無効な情報を送信。次にそのリンクから有効な情報を送信。期待どおりに動作することを確認する。


  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # 無効なメールアドレスの送信
    post password_resets_path, params: {password_reset: {email: ""}}
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # 有効なメールアドレスの送信
    post password_resets_path, params:{password_reset: {email: @user.email}}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # パスワード再設定フォームのテスト
    user = assigns(:user)
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # 無効なユーザー
    user.toggle!(:activated)
      # 引数に:activatedを渡すことでアカウント有効化の切り替えができる。!がついているから有効にしなかったってこと
    get edit_password_reset_path(user.reset_token,email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # メールアドレスが有効でトークンが無効
    get edit_password_reset_path('wrong token', email:user.email)
    assert_redirected_to root_url
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email:user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
      # input タグに正しい名前、type="hidden",メールアドレスがどうか確かめている。
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
    params:{ email: user.email,
          user:{password: "foobaz",
                password_confirmation: "barquux"}}
    assert_select 'div#error_explanation'
     # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    assert_select 'div#error_explanation'
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
    params: {email:user.email,
      user: {password:  "foobaz",
             password_confirmation: "foobaz"}}
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    assert_response :redirect
    follow_redirect!
    assert_match "expired", response.body
  end
end
