class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  # 同じログイン手法を様々な場所で使い回せるようにするためのメソッドを上記モジュールに記述
  private
  # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        # ログインしていなければ
        store_location
        # アクセスしようとしたURLを覚えておく
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
