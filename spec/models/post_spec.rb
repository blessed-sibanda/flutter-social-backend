require "rails_helper"

RSpec.describe Post, type: :model do
  describe "validations" do
    it { should validate_presence_of(:body) }
    it { should validate_length_of(:body).is_at_least(10) }
  end
end
