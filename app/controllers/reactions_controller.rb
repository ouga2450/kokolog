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

    @mood_logs =
      current_user.mood_logs
                  .includes(:mood, :feeling)
                  .for_date(@date)
                  .recent

    @habit_logs =
      current_user.habit_logs
                  .includes(:habit, mood_logs: :mood)
                  .for_date(@date)
                  .recent

    @habits =
      current_user.habits
                  .includes(:category, :goal)
                  .kept
                  .recent

    # --- 平均気分 ---
    @avg_mood =
      @mood_logs
        .joins(:mood)
        .average("moods.score")
        &.to_f

    # --- 日・週・月 の行動に分離 ---
    @daily_habits = @habits.daily
    @weekly_habits = @habits.weekly
    @monthly_habits = @habits.monthly

    # --- Progress 生成 ---
    @daily_progresses =
      @daily_habits.map do |habit|
        HabitProgress.new(habit: habit, date: @date, frequency: :daily)
      end

    @weekly_progresses =
      @weekly_habits.map do |habit|
        HabitProgress.new(habit: habit, date: @date, frequency: :weekly)
      end

    @monthly_progresses =
      @monthly_habits.map do |habit|
        HabitProgress.new(habit: habit, date: @date, frequency: :monthly)
      end

    # 達成率
    @daily_summary = HabitProgressSummary.new(@daily_progresses)
    @weekly_summary = HabitProgressSummary.new(@weekly_progresses)
    @monthly_summary = HabitProgressSummary.new(@monthly_progresses)

    @daily_rate = @daily_summary.achievement_rate
    @weekly_rate = @weekly_summary.achievement_rate
    @monthly_rate = @monthly_summary.achievement_rate

    # 件数
    @daily_done = @daily_summary.achieved_count
    @daily_total = @daily_summary.total
    @weekly_done = @weekly_summary.achieved_count
    @weekly_total = @weekly_summary.total
    @monthly_done = @monthly_summary.achieved_count
    @monthly_total = @monthly_summary.total

    # 表示用：行動ごとの before/after（1日複数回ある場合は「最新」を採用）
    latest_by_habit = @habit_logs.group_by(&:habit_id).transform_values { |logs| logs.max_by(&:started_at) }

    @habit_summaries =
      @habits.map do |habit|
        log = latest_by_habit[habit.id]
        before_mood, after_mood = moods_for(log)
        progress = HabitProgress.new(
          habit: habit,
          date: @date,
          frequency: habit.goal.frequency.to_sym
        )

        {
          habit: habit,
          done: log.present?,
          progress: progress,
          achieved: progress.achieved?,
          status: progress.status,
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
