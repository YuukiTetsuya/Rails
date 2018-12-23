class AddPasswordDigestToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_digest, :string                                #usersテーブルにpassword_digestカラム（データ型はstring）を追加
  end
end
