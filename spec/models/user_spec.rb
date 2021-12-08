require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(30) }
  end

  describe "associations" do
    it { should have_one_attached(:avatar_image) }
    it {
      should have_many(:fans).class_name("Relationship")
               .with_foreign_key("followed_id").dependent(:destroy)
    }
    it {
      should have_many(:followers).through(:fans).source(:follower)
    }
    it {
      should have_many(:heros).class_name("Relationship")
               .with_foreign_key("follower_id").dependent(:destroy)
    }
    it {
      should have_many(:following).through(:heros).source(:followed)
    }
  end

  it "has relationships with other users" do
    user1 = create :user
    user2 = create :user
    user3 = create :user
    user4 = create :user
    user5 = create :user
    user6 = create :user

    user1.followers << user2
    user1.followers << user3
    user1.following << user5

    user2.followers << user1
    user2.followers << user3
    user2.following << user5
    user2.following << user6

    expect(user1.reload.followers).to include(user2, user3)
    expect(user1.reload.followers.count).to eq(2)

    expect(user2.reload.following).to include(user1, user5, user6)
    expect(user2.reload.following.count).to eq(3)

    expect(user2.reload.followers).to include(user1, user3)
    expect(user2.reload.followers.count).to eq(2)

    expect(user3.reload.following).to include(user1, user2)
    expect(user3.reload.following.count).to eq(2)

    expect(user5.reload.followers).to include(user2, user1)
    expect(user5.reload.following.count).to eq 0
    expect(user5.reload.followers.count).to eq 2

    expect(user6.reload.followers).to include user2
    expect(user6.reload.followers.count).to eq 1
    expect(user6.reload.following.count).to eq 0
  end
end
