require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    # user.yml
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {user: {name: "",
                            email: "foo@invalid",
                            password: "foo",
                            password_confirmation: "bar"}}
    assert_template 'users/edit'
    assert_select 'div', "The form contains 4 errors."
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    assert_equal session[:forwarding_url], edit_user_url(@user)
    log_in_as(@user)
    # ログインする
    assert_nil session[:forwarding_url]
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: {user: {name: name,
                            email: email,
                            password: "",
                            password_confirmation: ""}}
    assert_not flash.empty?
    # flash配列の中身が空であればtrue 入っていればfalse assert_notは通る。flashの中身あるの？ていうテスト
    assert_redirected_to @user
    @user.reload
    # データベースから最新のユーザー情報を読み込み直して、正しく更新されたかどうかを確認している
    assert_equal name, @user.name
    # 左と右で比較する
    assert_equal email, @user.email
  end
end
