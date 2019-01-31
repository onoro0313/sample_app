class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
    # フレンドレーフォワーディングのrequest.urlと似ていて、1つ前のurlを返す。今回の場合はhomeページ。動きとしてはマイクロポストのdelete、プロフのデリートが行われた場合でもdeleteリクエストが発行されたページに戻すことができる。仮に元に戻すurlがなかった場合でも、||で、root_urlをデフォルトに設定しているためerrorはおきない
  end

  private
    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end
    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
      # @micropostが存在していなければ、deleteするものがないのでrootへ
    end
end
