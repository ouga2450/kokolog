class ReplaceArchivedWithArchivedAtInHabits < ActiveRecord::Migration[7.2]
  def up
    add_column :habits, :archived_at, :datetime

    # 既に archived = true のものは「今」アーカイブされた扱いにする
    execute <<~SQL
      UPDATE habits
      SET archived_at = CURRENT_TIMESTAMP
      WHERE archived = TRUE
    SQL

    remove_column :habits, :archived, :boolean
  end

  def down
    add_column :habits, :archived, :boolean

    execute <<~SQL
      UPDATE habits
      SET archived = TRUE
      WHERE archived_at IS NOT NULL
    SQL

    execute <<~SQL
      UPDATE habits
      SET archived = FALSE
      WHERE archived IS NULL
    SQL

    change_column_default :habits, :archived, false
    change_column_null :habits, :archived, false

    remove_column :habits, :archived_at, :datetime
  end
end
