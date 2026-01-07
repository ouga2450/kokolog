require "rails_helper"

RSpec.describe Feeling, type: :model do
  describe "associations" do
    it "has many mood_logs with dependent nullify" do
      assoc = described_class.reflect_on_association(:mood_logs)

      expect(assoc.macro).to eq(:has_many)
      expect(assoc.options[:dependent]).to eq(:nullify)
    end
  end

  describe "validations" do
    it "is valid with name" do
      feeling = build(:feeling)

      expect(feeling).to be_valid
      expect(feeling.errors).to be_empty
    end

    it "is invalid without name" do
      feeling = build(:feeling, name: nil)

      expect(feeling).not_to be_valid
    end

    it "is invalid with duplicate name" do
      create(:feeling, name: "Calm")
      feeling = build(:feeling, name: "Calm")

      expect(feeling).not_to be_valid
    end
  end
end
