class AddAdminToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :admin, :boolean, default: false
    # defaultで管理者になれないことを示すため
    # boolean 真理値の「真 = true」と「偽 = false」という2値をとるデータ型
  end
end
