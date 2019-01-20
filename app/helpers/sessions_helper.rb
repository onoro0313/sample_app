module SessionsHelper
  # includeはapplication controllerに記述
  # ログインする
  def log_in(user)
    session[:user_id] = user.id
    # sessionメソッドで作成した一時cookiesは自動的に暗号化され,コードは保護。cookiesから盗みだすことができたとしてもログインは不可。
    # →cookiesメソッドで作成した永続的セッションでは断定できない。
  end
  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    # インスタンスメソッド user.rbにて定義
    cookies.permanent.signed[:user_id] = user.id
    # cookiesメソッドでユーザーIDの永続cookiesを作成
    cookies.permanent[:remember_token] = user.remember_token
    #cookiesメソッドで記憶トークンの永続cookiesを作成
  end

  # current_userの定義
  def current_user
    if(user_id = session[:user_id])
      # if()内部, == ではない理由は、要件として(ユーザーIDにユーザーIDのセッションを代入した結果)ユーザーIDのセッションが存在すれば
    @current_user ||= User.find_by(id: session[:user_id])
    # findを使うとnilが引数になるとエラーを起こす。find_byはnilのまま返すので動作が止まらない。sessionにuser_idが入っていない可能性（ログインしていないだけ）がある場合はfind_by
    # User.find_byの実行結果をインスタンス変数(@current_user)に保存する工夫。呼び出し時に変数を使う。DBの行き来が減る。
    # if @current_user.nil? @current_user = User.find_by~はor演算子「||」を使えば@current_user = @current_user || User.find_by(id: session[:user_id])一行で書ける。さらに@current_user ||= User.find_by(id: session[:user_id])こっちの方が短く早い。代入演算子。
    elsif(user_id = cookies.signed[:user_id])
      user = User.find_by(id:user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

   # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
