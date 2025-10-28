class CreateMoods < ActiveRecord::Migration[7.2]
  def change
    create_table :moods do |t|
      t.integer :score, null: false
      t.string :label, null: false
      t.string :color, null: false

      t.timestamps
    end

    # 重複を避けるためのインデックスを追加
    add_index :moods, :score, unique: true
    add_index :moods, :label, unique: true
  end
end
