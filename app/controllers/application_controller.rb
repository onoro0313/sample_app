class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  # 同じログイン手法を様々な場所で使い回せるようにするためのメソッドを上記モジュールに記述
end
