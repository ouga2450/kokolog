require "rails_helper"

RSpec.describe Habit, type: :model do
  describe "associations" do
    it "belongs to user and category, has one goal, has many habit_logs" do
      user_assoc = described_class.reflect_on_association(:user)
      category_assoc = described_class.reflect_on_association(:category)
      goal_assoc = described_class.reflect_on_association(:goal)
      logs_assoc = described_class.reflect_on_association(:habit_logs)

      expect(user_assoc.macro).to eq(:belongs_to)
      expect(category_assoc.macro).to eq(:belongs_to)
      expect(goal_assoc.macro).to eq(:has_one)
      expect(goal_assoc.options[:dependent]).to eq(:destroy)
      expect(logs_assoc.macro).to eq(:has_many)
      expect(logs_assoc.options[:dependent]).to eq(:destroy)
    end
  end

  describe "validations" do
    it "is invalid without name" do
      habit = build(:habit, name: nil)
      expect(habit).not_to be_valid
    end
  end

  describe "scopes" do
    it "filters kept and discarded habits" do
      kept = create(:habit)
      discarded = create(:habit, :archived)

      expect(described_class.kept).to include(kept)
      expect(described_class.kept).not_to include(discarded)
      expect(described_class.discarded).to include(discarded)
      expect(described_class.discarded).not_to include(kept)
    end

    it "orders by recent updated_at" do
      older = create(:habit)
      newer = create(:habit)

      older.update_columns(updated_at: 2.days.ago)
      newer.update_columns(updated_at: Time.current)

      expect(described_class.recent.first).to eq(newer)
    end

    it "filters by goal frequency" do
      daily_habit = create(:habit)
      weekly_habit = create(:habit)
      monthly_habit = create(:habit)

      create(:goal, habit: daily_habit, user: daily_habit.user, frequency: :daily)
      create(:goal, habit: weekly_habit, user: weekly_habit.user, frequency: :weekly)
      create(:goal, habit: monthly_habit, user: monthly_habit.user, frequency: :monthly)

      expect(described_class.daily).to include(daily_habit)
      expect(described_class.weekly).to include(weekly_habit)
      expect(described_class.monthly).to include(monthly_habit)
    end

    it "filters by active goals effective on date" do
      date = Date.current
      active_habit = create(:habit)
      inactive_habit = create(:habit)
      out_of_range_habit = create(:habit)

      create(:goal, habit: active_habit, user: active_habit.user, status: :active, start_date: date - 1, end_date: date + 1)
      create(:goal, habit: inactive_habit, user: inactive_habit.user, status: :draft, start_date: date - 1, end_date: date + 1)
      create(:goal, habit: out_of_range_habit, user: out_of_range_habit.user, status: :active, start_date: date + 1, end_date: date + 2)

      results = described_class.with_active_goal.with_effective_goal_on(date)

      expect(results).to include(active_habit)
      expect(results).not_to include(inactive_habit)
      expect(results).not_to include(out_of_range_habit)
    end

    it "uses frequency-specific scopes for today/this week/this month" do
      daily_habit = create(:habit)
      weekly_habit = create(:habit)
      monthly_habit = create(:habit)

      create(:goal, habit: daily_habit, user: daily_habit.user, frequency: :daily)
      create(:goal, habit: weekly_habit, user: weekly_habit.user, frequency: :weekly)
      create(:goal, habit: monthly_habit, user: monthly_habit.user, frequency: :monthly)

      expect(described_class.for_today).to include(daily_habit)
      expect(described_class.for_today).not_to include(weekly_habit)
      expect(described_class.for_today).not_to include(monthly_habit)

      expect(described_class.for_this_week).to include(weekly_habit)
      expect(described_class.for_this_week).not_to include(daily_habit)
      expect(described_class.for_this_week).not_to include(monthly_habit)

      expect(described_class.for_this_month).to include(monthly_habit)
      expect(described_class.for_this_month).not_to include(daily_habit)
      expect(described_class.for_this_month).not_to include(weekly_habit)
    end
  end

  describe "instance methods" do
    it "archives and restores the habit" do
      habit = create(:habit)

      expect(habit.archived?).to be(false)

      habit.archive!
      expect(habit.archived?).to be(true)
      expect(habit.archived_at).not_to be_nil

      habit.restore!
      expect(habit.archived?).to be(false)
      expect(habit.archived_at).to be_nil
    end

    it "returns whether it was executed today" do
      habit = create(:habit)
      goal = create(:goal, user: habit.user, habit: habit)
      habit_log = create(:habit_log, user: habit.user, habit: habit, goal: goal, started_at: Time.current)

      expect(habit.executed_today?).to be(true)

      habit_log.update_columns(started_at: 2.days.ago)
      expect(habit.executed_today?).to be(false)
    end
  end
end
