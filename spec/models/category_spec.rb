require "rails_helper"

RSpec.describe Category, type: :model do
  describe "associations" do
    it "has many habits with dependent nullify" do
      assoc = described_class.reflect_on_association(:habits)

      expect(assoc.macro).to eq(:has_many)
      expect(assoc.options[:dependent]).to eq(:nullify)
    end
  end

  describe "validations" do
    it "is valid with required attributes" do
      category = build(:category)

      expect(category).to be_valid
      expect(category.errors).to be_empty
    end

    it "is invalid without name" do
      category = build(:category, name: nil)

      expect(category).not_to be_valid
    end

    it "is invalid with duplicate name" do
      create(:category, name: "Study")
      category = build(:category, name: "Study")

      expect(category).not_to be_valid
    end

    it "is invalid when icon is too long" do
      category = build(:category, icon: "a" * 11)
      expect(category).not_to be_valid
    end

    it "is valid with blank description" do
      category = build(:category, description: "")
      expect(category).to be_valid
    end

    it "is invalid when description is too long" do
      category = build(:category, description: "a" * 201)
      expect(category).not_to be_valid
    end
  end
end
