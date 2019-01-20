require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    # ログイン用のパスをかく
    assert_template 'sessions/new'
    # 新しいセッションのフォームが正しく表示されたかを確認
    post login_path, params: {session: { email:"",password: ""}}
    # わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
    assert_template 'sessions/new'
    assert_not flash.empty?
    # 新しいセッションのフォームが再度表示、フラッシュメッセージが追加されることを確認
    get root_path
    assert flash.empty?
  end

  test "login with valid information" do
    get login_path
    post login_path, params: {session: {email: @user.email, password: 'password'}}
    assert_redirected_to @user
    # リダイレクト先が正しいかどうかをチェック。
    follow_redirect!
    # そのページに実際に移動する。user_path #get
    assert_template 'users/show'
    assert_select "a[href=?]",login_path, count: 0
    # login_pathに値するリンクが0かどうかを確認する。路銀パスのリンクがページにないかどうかをチェック
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

  test "login with valid information followed by logout" do

    get login_path
    post login_path, params: { session: { email:    @user.email,password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    # post login_pathと一緒
    assert_not is_logged_in?
    # logoutしているか確認 is_logged_in?がfalseならok
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシュミレートする
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end

  test "login_with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies['remember_token']
  end

  test "login without remembering" do
    # クッキーを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # クッキーを削除してログイン
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
