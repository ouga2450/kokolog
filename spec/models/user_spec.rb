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

  describe ".from_omniauth" do
    # google認証済のユーザーがログインする場合
    context "when user with provider and uid already exists" do
      let!(:user) { create(:user, :google_linked) }

      let(:auth) do
        double(
          provider: "google_oauth2",
          uid: user.uid,
          info: double(
            email: user.email,
            name: "Ignored Name" # ユーザー名は変更されないこと
          )
        )
      end

      # 既存ユーザーが返ること
      it "returns the existing user" do
        expect {
          result = User.from_omniauth(auth)
          expect(result).to eq user
          expect(result.name).to eq "Google User" # 名前は変更されない
        }.not_to change(User, :count)
      end
    end

    # メールアドレスで登録したユーザーがgoogle認証で初ログインした場合
    context "when existing user with same email exists" do
      let!(:user) { create(:user, email: "test@gmail.com") }

      let(:auth) do
        double(
          provider: "google_oauth2",
          uid: "google-uid-123",
          info: double(
            email: "test@gmail.com",
            name: "Google User"
          )
        )
      end

      it "links google account to existing user" do
        original_encrypted_password = user.encrypted_password

        expect {
          User.from_omniauth(auth)
        }.not_to change(User, :count)

        user.reload
        expect(user.provider).to eq "google_oauth2"
        expect(user.uid).to eq "google-uid-123"
        expect(user.name).to eq "テストユーザー" # 名前は変更されない
        expect(user.encrypted_password).to eq original_encrypted_password # パスワードも変更されない
      end
    end

    # 新規ユーザーがgoogle認証でログインした場合
    context "when no matching user exists" do
      let(:auth) do
        double(
          provider: "google_oauth2",
          uid: "new-google-uid",
          info: double(
            email: "new_user@gmail.com",
            name: "New User"
          )
        )
      end

      it "creates a new user" do
        expect {
          User.from_omniauth(auth)
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.email).to eq "new_user@gmail.com"
        expect(user.name).to eq "New User"
        expect(user.provider).to eq "google_oauth2"
        expect(user.uid).to eq "new-google-uid"
      end
    end
  end
end
