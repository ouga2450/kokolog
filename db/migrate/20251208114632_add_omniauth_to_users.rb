class AddOmniauthToUsers < ActiveRecord::Migration[7.2]
  def change
    # すでに存在する場合はスキップ（本番・ローカル差分対策）
    add_column :users, :provider, :string, if_not_exists: true
    add_column :users, :uid, :string, if_not_exists: true
  end
end
