class HabitLogSaver
  # インスタンス変数の公開
  # controllerで使用
  attr_reader :habit_log

  def initialize(form)
    @form = form
    @user = form.user
    @habit_log = form.habit_log
  end

  # habit_log, before/after_mood_log 保存処理
  def save
    return false unless @form.valid?

    ActiveRecord::Base.transaction do
      habit_valid = save_habit_log

      @diffs = {
        before: save_mood(:before),
        after:  save_mood(:after)
      }

      # どこかにエラーが付いていたらまとめてロールバック
      raise ActiveRecord::Rollback if @form.errors.any? || !habit_valid
    end

    @form.errors.none?
  end

  # MoodLogDiffからの返り値
  # turbo_stream処理の場合分けに使用
  def diffs
    @diffs
  end

  private

  def save_habit_log
    @habit_log ||= @user.habit_logs.build

    @habit_log.assign_attributes(
      habit_id: @form.habit_id,
      goal_id: @form.goal_id,
      performed_value: @form.performed_value,
      started_at: @form.started_at,
      ended_at: @form.ended_at
    )

    return true if @habit_log.save

    @habit_log.errors.each { |e| @form.errors.add(e.attribute, e.message) }
    false
  end

  # before/after 気分保存処理
  # 返り値はMoodLogDiffの判定結果
  def save_mood(timing)
    # 保存前の元データとparams
    old = @habit_log.mood_logs.public_send(timing).first
    attrs = mood_params(timing)

    has_any_input = attrs.values.any?(&:present?)
    has_mood      = attrs[:mood_id].present?

    # 空欄 → 既存削除
    unless has_any_input
      old&.destroy
      return MoodLogDiff.diff(old, nil)
    end

    unless has_mood
      @form.errors.add("#{timing}_mood_id", :blank)
      return MoodLogDiff.diff(old, nil)
    end

    mood = old || @habit_log.mood_logs.build(timing: timing, user: @user)

    mood.assign_attributes(attrs.merge(timing: timing, recorded_at: recorded_time(timing)))

    # mood 保存エラーなら、@formにエラーを蓄積
    if mood.save
      MoodLogDiff.diff(old, mood)
    else
      mood.errors.each { |e| @form.errors.add("#{timing}_#{e.attribute}", e.message) }
      nil
    end
  end

  # before/after の気分params
  def mood_params(timing)
    {
      mood_id: @form.public_send("#{timing}_mood_id"),
      feeling_id: @form.public_send("#{timing}_feeling_id"),
      note: @form.public_send("#{timing}_note")
    }
  end

  # 気分の記録時間を行動の開始/終了時刻に合わせる
  def recorded_time(timing)
    timing == :before ? @habit_log.started_at : (@habit_log.ended_at || Time.current)
  end
end
