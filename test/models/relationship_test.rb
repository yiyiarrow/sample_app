require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @relationship = Relationship.new(follower_id: 1, followed_id: 2)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end  

  test "should require followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  test "should follow and unfollow a user" do
    xiaoming = users(:xiaoming)
    xiaohong = users(:xiaohong)
    assert_not xiaoming.following?(xiaohong)
    xiaoming.follow(xiaohong)
    assert xiaoming.following?(xiaohong)
    assert xiaohong.followers.include?(xiaoming)
    xiaoming.unfollow(xiaohong)
    assert_not xiaoming.following?(xiaohong)
  end
end
