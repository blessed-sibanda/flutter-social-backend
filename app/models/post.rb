class Post < ApplicationRecord
  self.per_page = 10
  belongs_to :user

  validates :body, presence: true, length: { minimum: 10 }
end
