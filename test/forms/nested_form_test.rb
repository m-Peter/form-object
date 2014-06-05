require 'test_helper'

class UserFormFixture
  attr_reader :model

  def initialize(model)
    @model = model
  end
end

class NestedFormTest < ActiveSupport::TestCase

  test "accepts the model it represents" do
    user = User.new
    user_form = UserFormFixture.new(user)

    assert_equal user, user_form.model
  end
end