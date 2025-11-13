class CreateHabits < ActiveRecord::Migration[7.2]
  def change
    create_table :habits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.string :name, null: false
      t.text :description
      t.boolean :archived, default: false, null: false

      t.timestamps
    end
  end
end
