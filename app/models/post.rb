class Post < ApplicationRecord
  belongs_to :user

  validates_presence_of :body
  validates_length_of :body, minimum: 10
end
