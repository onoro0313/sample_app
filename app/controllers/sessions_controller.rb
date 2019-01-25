class SessionsController < ApplicationController
  def new
    # debugger
  end
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&&user.authenticate(params[:session][:password])
    # 論理積/ 取得したユーザーが有効かどうかを決定するために使う。定番の方法。authenticate認証に失敗したときにfalseを返す
      if user.activated?
        log_in user
        # ログインする。一時的sessionを使う
        # moduleを使用。helper。
        params[:session][:remember_me] == '1'? remember(user) : forget(user)
        # if params[:session][:remember_me] == '1'
        #   remember(user)
        # else
        #   forget(user)
        # end
        # ログインしたユーザーを記憶する。具体的には記憶トークンの作成→ダイジェストハッシュ化データベース更新 attribute
        # moduleを使用。helper。
        redirect_back_or user
        # フレンドリーフォワーディングを実装。sessionhelperに記述あり。
      else
        message = "Account not activated"
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      # .now その後のリクエストが発生した時に消滅する。
      # Bootstrap CSSのおかげで適切なスタイル 赤レイアウト
      render 'new'
    end
  end
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end






