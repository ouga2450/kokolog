class CreateGoals < ActiveRecord::Migration[7.2]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :habit, null: false, foreign_key: true

      t.integer :goal_type, null: false, default: 0       # daily / weekly / monthly
      t.integer :status, null: false, default: 0          # draft / active / achieved
      t.integer :target_type, null: false, default: 0     # check / count / time
      t.integer :target_value                             # count or time
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
    # 複合インデックスの追加
    add_index :goals, [:user_id, :goal_type, :status]
    add_index :goals, :status
    add_index :goals, :goal_type
  end
end
