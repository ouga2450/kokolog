class HabitLogForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  def self.model_name
    ActiveModel::Name.new(self, nil, "HabitLog")
  end

  attr_reader :user, :habit_log, :habit

  # --- HabitLog attributes ---
  attribute :id, :integer
  attribute :habit_id, :integer
  attribute :goal_id, :integer
  attribute :performed_value, :integer
  attribute :started_at, :datetime
  attribute :ended_at, :datetime

  # --- before/after mood attributes ---
  %i[before after].each do |prefix|
    attribute "#{prefix}_mood_id", :integer
    attribute "#{prefix}_feeling_id", :integer
    attribute "#{prefix}_note", :string
  end

  # --- バリデーション ---
  validates :habit_id, :goal_id, :started_at, presence: true
  validates :performed_value,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # new/edit データ構成
  def initialize(user:, habit: nil, habit_log: nil, attributes: {})
    @user = user
    @habit_log = habit_log
    @habit = habit_log&.habit || habit

    defaults = default_attributes
    super(defaults.merge(attributes))
  end

  def persisted?
    habit_log&.persisted?
  end

  private

  # new/edit attributesセット
  def default_attributes
    return new_attributes unless habit_log
    edit_attributes
  end

  def new_attributes
    {
      habit_id: habit.id,
      goal_id: habit.goal&.id,
      started_at: Time.current
    }
  end

  def edit_attributes
    base = {
      id: habit_log.id,
      habit_id: habit_log.habit_id,
      goal_id: habit_log.goal_id,
      performed_value: habit_log.performed_value,
      started_at: habit_log.started_at,
      ended_at: habit_log.ended_at
    }

    base.merge(mood_attributes(:before))
        .merge(mood_attributes(:after))
  end

  # edit時 mood attributesセット
  def mood_attributes(timing)
    log = habit_log.mood_logs.public_send(timing).first
    return {} unless log

    {
      "#{timing}_mood_id": log.mood_id,
      "#{timing}_feeling_id": log.feeling_id,
      "#{timing}_note": log.note
    }
  end
end
