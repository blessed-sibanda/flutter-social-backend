class User < ApplicationRecord
  self.per_page = 10
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenyList

  validates :name, presence: true, length: { in: 3..30 }

  has_one_attached :avatar_image

  has_many :fans, class_name: "Relationship",
                  foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :fans, source: :follower

  has_many :heros, class_name: "Relationship",
                   foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :heros, source: :followed
end
