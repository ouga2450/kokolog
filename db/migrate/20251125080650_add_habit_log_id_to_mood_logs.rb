class AddHabitLogIdToMoodLogs < ActiveRecord::Migration[7.2]
  def change
    add_reference :mood_logs, :habit_log, null: true, foreign_key: true
  end
end
