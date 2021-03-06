require "rails_helper"

RSpec.describe Comment, type: :model do
  describe "validations" do
    it { should validate_presence_of(:body) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:post) }
  end

  it do
    expect(Comment.per_page > 0).to be_truthy
  end
end
