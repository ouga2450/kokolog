class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
       :registerable,
       :recoverable,
       :rememberable,
       :validatable,
       :omniauthable, omniauth_providers: [ :google_oauth2 ]

  # --- 関連 ---
  has_many :mood_logs, dependent: :destroy
  has_many :habit_logs, dependent: :destroy
  has_many :habits, dependent: :destroy
  has_many :goals, dependent: :destroy

  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }

  def self.from_omniauth(auth)
    # provider / uid が一致するユーザーがいればそのままログイン
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    # メールアドレスが一致する既存ユーザーがいればgoogleに紐づけ
    user = find_by(email: auth.info.email)
    if user
      user.update(
        provider: auth.provider,
        uid: auth.uid,
      )
      return user
    end
    create(
      name: auth.info.name,
      email: auth.info.email,
      password: Devise.friendly_token[0,20],
      provider: auth.provider,
      uid: auth.uid
    )
  end

  def self.create_unique_string
    SecureRandom.uuid
  end
end
