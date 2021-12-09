require "rails_helper"

RSpec.describe Like, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:likable) }
  end

  it do
    expect(Like.per_page > 0).to be_truthy
  end
end
