module SessionsHelper
  # includeはapplication controllerに記述
  def log_in(user)
    session[:user_id] = user.id
    # sessionメソッドで作成した一時cookiesは自動的に暗号化され,コードは保護。cookiesから盗みだすことができたとしてもログインは不可。
    # →cookiesメソッドで作成した永続的セッションでは断定できない。
  end

  # current_userの定義
  def current_user
    if session[:user_id]
    @current_user ||= User.find_by(id: session[:user_id])
    # findを使うとnilが引数になるとエラーを起こす。find_byはnilのまま返すので動作が止まらない。sessionにuser_idが入っていない可能性（ログインしていないだけ）がある場合はfind_by
    # User.find_byの実行結果をインスタンス変数(@current_user)に保存する工夫。呼び出し時に変数を使う。DBの行き来が減る。
    # if @current_user.nil? @current_user = User.find_by~はor演算子「||」を使えば@current_user = @current_user || User.find_by(id: session[:user_id])一行で書ける。さらに@current_user ||= User.find_by(id: session[:user_id])こっちの方が短く早い。代入演算子。
    end
  end

   # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
