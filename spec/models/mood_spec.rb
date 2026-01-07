require "rails_helper"

RSpec.describe Mood, type: :model do
  describe "associations" do
    it "has many mood_logs" do
      assoc = described_class.reflect_on_association(:mood_logs)
      expect(assoc.macro).to eq(:has_many)
    end
  end

  describe "validations" do
    it "is valid with required attributes" do
      mood = build(:mood)
      expect(mood).to be_valid
    end

    it "is invalid without score" do
      mood = build(:mood, score: nil)
      expect(mood).not_to be_valid
    end

    it "is invalid with duplicate score" do
      create(:mood, score: 1)
      mood = build(:mood, score: 1)
      expect(mood).not_to be_valid
    end

    it "is invalid without label" do
      mood = build(:mood, label: nil)
      expect(mood).not_to be_valid
    end

    it "is invalid with duplicate label" do
      create(:mood, label: "very good")
      mood = build(:mood, label: "very good")

      expect(mood).not_to be_valid
    end

    it "is invalid without color" do
      mood = build(:mood, color: nil)
      expect(mood).not_to be_valid
    end
  end
end
