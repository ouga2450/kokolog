require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with all required attributes" do
      user = build(:user)

      expect(user).to be_valid
      expect(user.errors).to be_empty
    end

    it "is valid for google linked user" do
      user = build(:user, :google_linked)

      expect(user).to be_valid
      expect(user.errors).to be_empty
    end

    it "is invalid without email" do
      user = build(:user, email: nil)

      expect(user).not_to be_valid
    end

    it "is invalid with duplicate email" do
      create(:user, email: "test@example.com")
      user = build(:user, email: "test@example.com")

      expect(user).not_to be_valid
    end

    it "is invalid when password is too short" do
      user = build(:user, password: "12345")
      expect(user).not_to be_valid
    end
  end
end
