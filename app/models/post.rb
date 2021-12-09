class Post < ApplicationRecord
  self.per_page = 10
  belongs_to :user
  has_many :comments
  has_many :likes, as: :likable

  validates :body, presence: true, length: { minimum: 10 }
  has_one_attached :image
end
