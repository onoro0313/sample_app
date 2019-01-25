require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  # indexのページを不正なアクセスから守るために、indexアクションが正しくリダイレクトするかを検証する。
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end
  test "should get new" do
    get signup_path
    assert_response :success
  end
  # beforeフィルターの実装
  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    # flashの配列の中身が空ならtrueで通らない。
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: {user: {name: @user.name,
                            email: @user.email}}
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    # 初期値はfalse
    patch user_path(@other_user), params: {
                    user: {password: @other_user.password,
                      password_confirmation: @other_user.password,
                      admin: true}}
    assert_not @other_user.reload.admin?
    # reload、データベースからレコードを再取得する。更新内容の反映。
    # このテストが通るということはデータベース内のadminがfalseのままであるということ
  end
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    # flashの配列の中身が空なら通る。flashが出ないことの確認
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params:{user: {name: @user.name,
                            email: @user.email}}
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
    #assert_no_differenceのブロックを実行する前後で引数の値(User.count)が変わらないことをテスト。ユーザー数を覚え、削除されていないかを検証する
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end
