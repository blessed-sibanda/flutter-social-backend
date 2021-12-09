class Comment < ApplicationRecord
  self.per_page = 10

  belongs_to :user
  belongs_to :post

  validates :body, presence: true
end
