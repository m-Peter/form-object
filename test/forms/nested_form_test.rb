require 'test_helper'

class UserFormFixture
  attr_reader :model
  attr_accessor :name, :age, :gender

  def initialize(model)
    @model = model
  end
end

class NestedFormTest < ActiveSupport::TestCase

  def setup
    @user = User.new
    @user_form = UserFormFixture.new(@user)
  end

  test "accepts the model it represents" do
    assert_equal @user, @user_form.model
  end

  test "declares attributes for the model" do
    attributes = [:name, :name=, :age, :age=, :gender, :gender=]

    attributes.each do |attribute|
      assert_respond_to @user_form, attribute
    end
  end
end