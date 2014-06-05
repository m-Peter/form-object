require 'test_helper'

class UserFormFixture
  include ActiveModel::Model

  attr_reader :model
  delegate :name, :name=, :age, :age=, :gender, :gender=, to: :model

  validates :name, :age, :gender, presence: true
  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }

  def initialize(model)
    @model = model
  end

  def submit(params)
    params.each do |key, value|
      send("#{key}=", value)
    end
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        @model.save
      end
    else
      false
    end
  end

  def valid?
    super
    @model.valid?
    @model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
    errors.empty?
  end

  def persisted?
    @model.persisted?
  end

  def to_key
    return nil unless persisted?
    @model.id
  end

  def to_param
    return nil unless persisted?
    @model.id.to_s
  end

  def to_partial_path
    ""
  end

  def to_model
    @model
  end
end

class NestedFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @user = User.new
    @user_form = UserFormFixture.new(@user)
    @model = @user_form
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

  test "validates the model" do
    peter = users(:peter)
    @user_form.name = peter.name
    @user_form.age = 23
    @user_form.gender = 0

    assert_not @user_form.valid?
    assert_includes @user_form.errors.messages[:name], "has already been taken"
  end

  test "sync the model with submitted data" do
    params = {
      name: "Peters",
      age: "23",
      gender: "0"
    }

    @user_form.submit(params)

    assert_equal "Peters", @user_form.name
    assert_equal 23, @user_form.age
    assert_equal 0, @user_form.gender
  end

  test "saves the model" do
    params = {
      name: "Peters",
      age: "23",
      gender: "0"
    }

    @user_form.submit(params)

    assert_difference('User.count') do
      @user_form.save
    end
  end

  test "does not save the model with invalid data" do
    params = {
      name: "m-peter",
      age: "23",
      gender: "0"
    }

    @user_form.submit(params)

    assert_not @user_form.valid?
    assert_difference('User.count', 0) do
      @user_form.save
    end
    assert_includes @user_form.errors.messages[:name], "has already been taken"
  end

  test "responds to #persisted?" do
    assert_respond_to @user_form, :persisted?
    assert_not @user_form.persisted?
    assert save_user
    assert @user_form.persisted?
  end

  test "responds to #to_key" do
    assert_respond_to @user_form, :to_key
    assert_nil @user_form.to_key
    assert save_user
    assert_equal @user.id, @user_form.to_key
  end

  test "responds to #to_param" do
    assert_respond_to @user_form, :to_param
    assert_nil @user_form.to_param
    assert save_user
    assert_equal @user.to_param, @user_form.to_param
  end

  test "responds to #to_partial_path" do
    assert_respond_to @user_form, :to_partial_path
    assert_instance_of String, @user_form.to_partial_path
  end

  test "responds to #to_model" do
    assert_respond_to @user_form, :to_model
    assert_equal @user, @user_form.to_model
  end

  private

  def save_user
    @user_form.name = "Peters"
    @user_form.age = 23
    @user_form.gender = 0

    @user_form.save
  end
end