class HabitForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # --- Habit の属性 ---
  attribute :id, :integer
  attribute :name, :string
  attribute :description, :string
  attribute :category_id, :integer
  attribute :user_id, :integer

  # --- Goal の属性 ---
  attribute :goal_type, :string      # enum は string で扱ってOK
  attribute :target_type, :string    # enum
  attribute :target_value, :integer
  attribute :start_date, :date
  attribute :end_date, :date

  # attr_reader（@habit や @goal にアクセス）
  attr_reader :habit, :goal

  # --- バリデーション ---

  # Habit用
  validates :name, :category_id, :user_id, presence: true
  # Goal用
  validates :goal_type, :target_type, presence: true
  # target_value は target_type によって条件付き必須
  validates :target_value,
    numericality: { greater_than: 0 },
    if: -> { target_type.in?(%w[count_based time_based]) }

  # start_date > end_date ならエラー
  validate :start_date_must_be_before_end_date

  # 編集用フォームオブジェクトを生成
  # habit は controller から渡される既存レコード
  def self.from_model(habit)
    goal = habit.goal

    new(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      category_id: habit.category_id,
      user_id: habit.user_id,
      goal_type: goal.goal_type,
      target_type: goal.target_type,
      target_value: goal.target_value,
      start_date: goal.start_date,
      end_date: goal.end_date
    )
  end

  # --- 保存処理 ---
  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      # ---各モデルの新規作成---
      habit = Habit.create!(
        name: name,
        description: description,
        category_id: category_id,
        user_id: user_id,
        archived: false
      )

      Goal.create!(
        user_id: user_id,
        habit_id: habit.id,
        goal_type: goal_type,
        target_type: target_type,
        target_value: target_value,
        start_date: start_date,
        end_date: end_date,
        status: :active  # 新規は active が妥当
      )
    end

    true
  rescue ActiveRecord::RecordInvalid # 例外時に false を返す
    false
  end

  # --- 更新処理 ---
  def update
    return false unless valid?

    ActiveRecord::Base.transaction do
      habit = Habit.find(id)
      goal = habit.goal

      # habitの更新
      habit.update!(
        name: name,
        description: description,
        category_id: category_id
      )

      # goalの更新
      goal.update!(
        goal_type: goal_type,
        target_type: target_type,
        target_value: target_value,
        start_date: start_date,
        end_date: end_date
      )
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end


  private

  def start_date_must_be_before_end_date
    return if start_date.blank? || end_date.blank?
    if start_date > end_date
      errors.add(:start_date, "は終了日より前に設定してください")
    end
  end
end
