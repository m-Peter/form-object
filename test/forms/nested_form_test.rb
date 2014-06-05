require 'test_helper'

class UserFormFixture
  include ActiveModel::Validations

  attr_reader :model
  delegate :name, :name=, :age, :age=, :gender, :gender=, to: :model

  validates :name, :age, :gender, presence: true
  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }

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

  test "delegates attributes to the model" do
    @user_form.name = "Peter"
    @user_form.age = 23
    @user_form.gender = 0

    assert_equal "Peter", @user.name
    assert_equal 23, @user.age
    assert_equal 0, @user.gender
  end

  test "validates itself" do
    @user_form.name = nil
    @user_form.age = nil
    @user_form.gender = nil

    assert_not @user_form.valid?
    assert_includes @user_form.errors.messages[:name], "can't be blank"
    assert_includes @user_form.errors.messages[:age], "can't be blank"
    assert_includes @user_form.errors.messages[:gender], "can't be blank"

    @user_form.name = "Peters"
    @user_form.age = 23
    @user_form.gender = 0

    assert @user_form.valid?
  end
end