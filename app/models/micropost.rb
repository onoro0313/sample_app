class Micropost < ApplicationRecord
  belongs_to :user
  # ラムダ式 -> はブロックを引数にProcオブジェ区を返す。callメソッドが呼ばれた時ブロック内の処理を評価する。
  default_scope -> {order(created_at: :desc)}
  mount_uploader :picture, PictureUploader
  # carrierwaveに画像と関連づけたモデルを伝えるためにはmount_uploaderというメソッドを使う。引数に属性名のシンボルと生成されたアップローダーのクラス名を取る。属性メイトは、カラム名のこと
  # 存在性のバリデーション
  validates :user_id, presence: true
  # contentに対するバリデーション
  validates :content, presence:true, length: {maximum: 140}
  validate :picture_size
  # validatesではなくてvalidate。引数にシンボルをとり、そのsシンボル名に対応したメソッドを呼ぶ
  # これらのvalidationをビューに組み込むために今回の場合は、file_fieldタグにacceptパラメーターを付与して使う。plus jqueryの書き加え
  private
  # アップロードされた画像のサイズをバリデーションする
  # uploader.rbには既存のオプションがないので

  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
      # validateが失敗した際に作られるerrorsオブジェクトに対して、pictureのsizeが5MB以上だった場合,addメソッドを使用して、特定の(Micropostモデルクラスが持つ、picture属性（カラム名）)属性に関連するエラーメッセージを手動で追加する。

    end
  end
end
