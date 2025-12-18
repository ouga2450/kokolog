class ReactionsController < ApplicationController
  def index
    # HabitLog と MoodLog のタイムスタンプから日付一覧を作成
    log_dates =
      current_user.habit_logs.pluck(:started_at) +
      current_user.mood_logs.pluck(:recorded_at)

    @dates = log_dates
      .compact                  # nil を除外
      .map(&:to_date)           # 日付に変換
      .uniq
      .sort
      .reverse                  # 新しい日付から順に

    # 日付ごとの件数集計
    @log_counts = @dates.index_with do |date|
      {
        habit_logs: current_user.habit_logs.where(started_at: date.all_day).count,
        mood_logs:  current_user.mood_logs.where(recorded_at: date.all_day).count
      }
    end
  end

  def show
    @date = parse_date(params[:date]) || Time.zone.today
    range = @date.beginning_of_day..@date.end_of_day

    # その日の気分ログ（単体 + 習慣ログ紐づきのどちらでも）
    @mood_logs =
      current_user.mood_logs
                  .includes(:mood, :feeling)
                  .where(recorded_at: range)
                  .order(:recorded_at)

    # その日の習慣ログ
    @habit_logs =
      current_user.habit_logs
                  .includes(:habit, mood_logs: :mood)
                  .where(started_at: range)
                  .order(started_at: :desc)

    # 対象となる「その日に有効だった習慣」：まずは active を母数にする（設計が変わるならここだけ直す）
    @habits =
      current_user.habits
                  .includes(:category, :goal)
                  .kept
                  .with_active_goal
                  .order(:created_at)

    # --- 平均気分（数字を出す） ---
    # mood.value が数値(例: 1..5) という前提。違うならここをあなたの実装に合わせて調整。
    @avg_mood =
      @mood_logs
        .joins(:mood)
        .average("moods.score")
        &.to_f

    # --- 達成率（成果として出す / ただし責めない見せ方は view で） ---
    @habits_count = @habits.size

    # “達成”の定義：その日に habit_log が1件でもあれば「その習慣は達成」扱い（まずはシンプルに）
    completed_habit_ids = @habit_logs.map(&:habit_id).uniq
    @completed_habits_count = completed_habit_ids.size

    @achievement_rate =
      if @habits_count.positive?
        ((@completed_habits_count.to_f / @habits_count) * 100).round
      else
        nil
      end

    # 表示用：習慣ごとの before/after（1日複数回ある場合は「最新」を採用）
    latest_by_habit = @habit_logs.group_by(&:habit_id).transform_values { |logs| logs.max_by(&:started_at) }

    @habit_summaries =
      @habits.map do |habit|
        log = latest_by_habit[habit.id]
        before_mood, after_mood = moods_for(log)
        {
          habit: habit,
          done: log.present?,
          before_mood: before_mood,
          after_mood: after_mood,
          started_at: log&.started_at
        }
      end
  end

  private

  def moods_for(log)
    return [nil, nil] unless log

    before_log = log.mood_logs.before.max_by(&:recorded_at)
    after_log = log.mood_logs.after.max_by(&:recorded_at)

    [before_log&.mood, after_log&.mood]
  end

  def parse_date(str)
    return nil if str.blank?
    Date.parse(str)
  rescue ArgumentError
    nil
  end
end
