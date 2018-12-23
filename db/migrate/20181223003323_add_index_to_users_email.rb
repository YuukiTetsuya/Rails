class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email, unique: true                                      #usersテーブルのemailカラムに、一意（重複のない）のインデックスを追加
  end
end
