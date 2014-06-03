require 'test_helper'

class UserFormTest < ActiveSupport::TestCase
  def setup
    @user = User.new
    @user_form = UserForm.new(@user)
  end

  test "accepts the model it represents" do
    assert_equal @user, @user_form.user
  end

  test "responds to the model attributes" do
    attributes = [:name, :name=, :age, :age=, :gender, :gender=]

    attributes.each do |attribute|
      assert_respond_to @user_form, attribute 
    end
  end

  test "delegate the attributes to its model" do
    @user_form.name = "Peter"
    @user_form.age = 23
    @user_form.gender = 0

    assert_equal "Peter", @user.name
    assert_equal 23, @user.age
    assert_equal 0, @user.gender
  end
end