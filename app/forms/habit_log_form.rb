class HabitLogForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # パラメータ名を既存の habit_log に合わせる
  def self.model_name
    ActiveModel::Name.new(self, nil, "HabitLog")
  end

  attr_reader :user, :habit_log, :habit

  # --- HabitLog の属性 ---
  attribute :id, :integer
  attribute :habit_id, :integer
  attribute :goal_id, :integer
  attribute :performed_value, :integer
  attribute :started_at, :datetime
  attribute :ended_at, :datetime

  # --- before mood の属性 ---
  attribute :before_mood_id, :integer
  attribute :before_feeling_id, :integer
  attribute :before_note, :string

  # --- after mood の属性 ---
  attribute :after_mood_id, :integer
  attribute :after_feeling_id, :integer
  attribute :after_note, :string

  # --- バリデーション ---
  validates :habit_id, :goal_id, :started_at, presence: true
  validates :performed_value,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  def initialize(user:, habit: nil, habit_log: nil, attributes: {})
    @user = user
    @habit_log = habit_log
    @habit = habit_log&.habit || habit

    # newならdefaultsのまま、editなら引数に上書き
    defaults = build_default_attributes
    super(defaults.merge(attributes))
  end

  def persisted?
    id.present?
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      log = habit_log || user.habit_logs.build
      log.assign_attributes(
        habit_id: habit_id,
        goal_id: goal_id,
        performed_value: performed_value,
        started_at: started_at,
        ended_at: ended_at
      )
      log.save!

      save_before_mood_log(log)
      save_after_mood_log(log)

      @habit_log = log
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  # --- 初期値を組み立てる ---
  def build_default_attributes
    if habit_log
      {
        id: habit_log.id,
        habit_id: habit_log.habit_id,
        goal_id: habit_log.goal_id,
        performed_value: habit_log.performed_value,
        started_at: habit_log.started_at,
        ended_at: habit_log.ended_at
      }.merge(default_before_mood_attrs)
       .merge(default_after_mood_attrs)
    else
      {
        habit_id: habit.id,
        goal_id: habit.goal&.id,
        started_at: Time.current
      }
    end
  end

  def default_before_mood_attrs
    before = habit_log&.mood_logs&.before&.first
    return {} unless before

    {
      before_mood_id: before.mood_id,
      before_feeling_id: before.feeling_id,
      before_note: before.note
    }
  end

  def default_after_mood_attrs
    after = habit_log&.mood_logs&.after&.first
    return {} unless after

    {
      after_mood_id: after.mood_id,
      after_feeling_id: after.feeling_id,
      after_note: after.note
    }
  end

  # --- before mood の保存 ---
  def save_before_mood_log(log)
    before = log.mood_logs.before.first

    # 入力が完全に空 → 削除して終了
    unless before_filled?
      before&.destroy
      return true
    end

    unless before_valid_input?
      raise ActiveRecord::RecordInvalid.new(before || MoodLog.new)
    end

    # 保存処理
    before ||= log.mood_logs.build(timing: :before, user: user)
    before.assign_attributes(
      mood_id: before_mood_id,
      feeling_id: before_feeling_id,
      note: before_note,
      recorded_at: log.started_at || Time.current
    )

    before.save!  # 例外が出ればトランザクションでロールバック
  end

  # --- after mood の保存 ---
  def save_after_mood_log(log)
    after = log.mood_logs.after.first

    # 入力が完全に空 → 削除して終了
    unless after_filled?
      after&.destroy
      return true
    end

    unless after_valid_input?
      raise ActiveRecord::RecordInvalid.new(after || MoodLog.new)
    end

    # 保存処理
    after ||= log.mood_logs.build(timing: :after, user: user)
    after.assign_attributes(
      mood_id: after_mood_id,
      feeling_id: after_feeling_id,
      note: after_note,
      recorded_at: log.ended_at || Time.current
    )

    after.save!  # 例外が出ればトランザクションでロールバック
  end

  def before_filled?
    before_mood_id.present? ||
    before_feeling_id.present? ||
    before_note.present?
  end

  def before_valid_input?
    before_mood_id.present?
  end


  def after_filled?
    after_mood_id.present? ||
    after_feeling_id.present? ||
    after_note.present?
  end

  def after_valid_input?
    after_mood_id.present?
  end
end
