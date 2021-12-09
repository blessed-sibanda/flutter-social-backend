class Like < ApplicationRecord
  self.per_page = 20
  belongs_to :user
  belongs_to :likable, polymorphic: true
end
