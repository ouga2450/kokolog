require "rails_helper"

RSpec.describe Goal, type: :model do
  let(:user) { create(:user) }

  # goalと紐づけるhabitを用意するヘルパーメソッド
  def build_goal(attrs = {})
    habit = attrs.delete(:habit) || create(:habit, user: user)
    build(:goal, user: user, habit: habit, **attrs)
  end

  def create_goal(attrs = {})
    habit = attrs.delete(:habit) || create(:habit, user: user)
    create(:goal, user: user, habit: habit, **attrs)
  end

  describe "associations" do
    it "belongs to user and habit, has many habit_logs" do
      user_assoc = described_class.reflect_on_association(:user)
      habit_assoc = described_class.reflect_on_association(:habit)
      logs_assoc = described_class.reflect_on_association(:habit_logs)

      expect(user_assoc.macro).to eq(:belongs_to)
      expect(habit_assoc.macro).to eq(:belongs_to)
      expect(logs_assoc.macro).to eq(:has_many)
      expect(logs_assoc.options[:dependent]).to eq(:destroy)
    end
  end

  describe "validations" do
    it "is invalid without goal_unit" do
      goal = build_goal(goal_unit: nil)
      expect(goal).not_to be_valid
    end

    it "is invalid without frequency" do
      goal = build_goal(frequency: nil)
      expect(goal).not_to be_valid
    end

    it "is invalid without status" do
      goal = build_goal(status: nil)
      expect(goal).not_to be_valid
    end

    it "sets amount to 1 for check_based" do
      goal = build_goal(goal_unit: :check_based, amount: nil)
      goal.valid?
      expect(goal.amount).to eq(1)
    end

    it "requires amount for count_based" do
      goal = build_goal(goal_unit: :count_based, amount: nil)
      expect(goal).not_to be_valid
    end

    it "is invalid when amount is not positive for count_based" do
      goal = build_goal(goal_unit: :count_based, amount: 0)
      expect(goal).not_to be_valid
    end

    it "is invalid when start_date is after end_date" do
      goal = build_goal(start_date: Date.current, end_date: Date.current - 1, amount: 1)
      expect(goal).not_to be_valid
    end
  end

  describe "scopes" do
    it "returns only active goals effective on the date" do
      date = Date.current
      active_goal = create_goal(start_date: date - 1, end_date: date + 1, status: :active)
      inactive_goal = create_goal(start_date: date - 1, end_date: date + 1, status: :draft)
      out_of_range = create_goal(start_date: date + 1, end_date: date + 2, status: :active)

      results = described_class.effective_on(date)

      expect(results).to include(active_goal)
      expect(results).not_to include(inactive_goal)
      expect(results).not_to include(out_of_range)
    end

    it "filters by frequency for today/this week/this month" do
      daily_goal = create_goal(frequency: :daily)
      weekly_goal = create_goal(frequency: :weekly)
      monthly_goal = create_goal(frequency: :monthly)

      expect(described_class.for_today).to include(daily_goal)
      expect(described_class.for_today).not_to include(weekly_goal)
      expect(described_class.for_today).not_to include(monthly_goal)

      expect(described_class.for_this_week).to include(weekly_goal)
      expect(described_class.for_this_week).not_to include(daily_goal)
      expect(described_class.for_this_week).not_to include(monthly_goal)

      expect(described_class.for_this_month).to include(monthly_goal)
      expect(described_class.for_this_month).not_to include(daily_goal)
      expect(described_class.for_this_month).not_to include(weekly_goal)
    end
  end

  describe "#display_goal" do
    it "includes amount for count_based" do
      goal = build_goal(goal_unit: :count_based, amount: 3, frequency: :weekly)
      expect(goal.display_goal).to include("3")
    end

    it "returns a string for check_based" do
      goal = build_goal(goal_unit: :check_based, amount: nil)
      expect(goal.display_goal).to be_a(String)
      expect(goal.display_goal).not_to be_empty
    end
  end

  describe "#display_period" do
    it "includes start_date and end_date when both are present" do
      start_date = Date.current
      end_date = Date.current + 7
      goal = build_goal(start_date: start_date, end_date: end_date)

      expect(goal.display_period).to include(start_date.to_s)
      expect(goal.display_period).to include(end_date.to_s)
    end

    it "includes only start_date when end_date is nil" do
      start_date = Date.current
      goal = build_goal(start_date: start_date, end_date: nil)

      expect(goal.display_period).to include(start_date.to_s)
    end
  end
end
