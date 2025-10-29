class CreateMoodLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :mood_logs do |t|
      # --- 必須（null: false） ---
      t.references :user,        null: false, foreign_key: true
      t.references :mood,        null: false, foreign_key: true
      t.datetime   :recorded_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      # --- 任意（null: true） ---
      # t.references :habit_log,   null: true, foreign_key: true 将来追加
      t.references :feeling,     null: true, foreign_key: true
      t.string     :timing,      null: true
      t.text       :note,        null: true

      t.timestamps
    end
  end
end
