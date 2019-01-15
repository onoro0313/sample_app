class SessionsController < ApplicationController
  def new
  end
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&&user.authenticate(params[:session][:password])
    # 論理積/ 取得したユーザーが有効かどうかを決定するために使う。定番の方法。authenticate認証に失敗したときにfalseを返す
      log_in user
      # moduleを使用。
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      # .now その後のリクエストが発生した時に消滅する。
      # Bootstrap CSSのおかげで適切なスタイル 赤レイアウト
      render 'new'
    end
  end
  def destroy
    log_out
    redirect_to root_url
  end
end
