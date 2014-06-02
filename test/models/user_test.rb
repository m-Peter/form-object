require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "requires unique name" do
    peter = users(:peter)
    new_user = User.create(name: peter.name, age: 24, gender: 0)

    assert_not new_user.valid?
  end
end
