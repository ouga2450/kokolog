class CreateFeelings < ActiveRecord::Migration[7.2]
  def change
    create_table :feelings do |t|
      t.string :name

      t.timestamps
    end

    add_index :feelings, :name, unique: true
  end
end
