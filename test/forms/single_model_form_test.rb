require 'test_helper'
require_relative 'single_model_form'

class SingleModelFormTest < ActiveSupport::TestCase
  def setup
    @user = User.new
    @form = SingleModelForm.new(@user)
  end

  test "accepts the model it represents" do
    assert_equal @user, @form.model
  end

  test "declares attributes for the model" do
    attributes = [:name, :name=, :age, :age=, :gender, :gender=]

    attributes.each do |attribute|
      assert_respond_to @form, attribute
    end
  end

  test "delegates attributes to the model" do
    @form.name = "Peter"
    @form.age = 23
    @form.gender = 0

    assert_equal "Peter", @user.name
    assert_equal 23, @user.age
    assert_equal 0, @user.gender
  end

  test "validates itself" do
    @form.name = nil
    @form.age = nil
    @form.gender = nil

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "can't be blank"
    assert_includes @form.errors.messages[:age], "can't be blank"
    assert_includes @form.errors.messages[:gender], "can't be blank"

    @form.name = "Peters"
    @form.age = 23
    @form.gender = 0

    assert @form.valid?
  end

  test "validates the model" do
    peter = users(:peter)
    @form.name = peter.name
    @form.age = 23
    @form.gender = 0

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "has already been taken"
  end

  test "sync the model with submitted data" do
    params = {
      name: "Peters",
      age: "23",
      gender: "0"
    }

    @form.submit(params)

    assert_equal "Peters", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
  end

  test "saves the model" do
    params = {
      name: "Peters",
      age: "23",
      gender: "0"
    }

    @form.submit(params)

    assert_difference('User.count') do
      @form.save
    end

    assert_equal "Peters", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
  end

  test "does not save the model with invalid data" do
    peter = users(:peter)
    params = {
      name: peter.name,
      age: "23",
      gender: "0"
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_difference('User.count', 0) do
      @form.save
    end
    assert_includes @form.errors.messages[:name], "has already been taken"
  end
end