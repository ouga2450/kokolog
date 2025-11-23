class RenameGoalColumns < ActiveRecord::Migration[7.2]
  def change
    rename_column :goals, :goal_type, :goal_unit
    rename_column :goals, :target_type, :frequency
    rename_column :goals, :target_value, :amount
  end
end
