class CreateHabitLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :habit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :habit, null: false, foreign_key: true
      t.references :goal, null: false, foreign_key: true

      # 実行記録
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.integer  :performed_value   # 回数 or 分数（count/time のため）

      t.timestamps
    end
    # 複合インデックスの追加
    add_index :habit_logs, :started_at
    add_index :habit_logs, [:user_id, :habit_id]
  end
end
