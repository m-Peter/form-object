require 'test_helper'

class UserFormTest < ActiveSupport::TestCase
  def setup
    @user = User.new
    @email = Email.new
    @user_form = UserForm.new(@user, @email)
  end

  test "accepts the User model" do
    assert_equal @user, @user_form.user
  end

  test "responds to the User attributes" do
    attributes = [:name, :name=, :age, :age=, :gender, :gender=]

    attributes.each do |attribute|
      assert_respond_to @user_form, attribute 
    end
  end

  test "delegate the attributes to User" do
    @user_form.name = "Peter"
    @user_form.age = 23
    @user_form.gender = 0

    assert_equal "Peter", @user.name
    assert_equal 23, @user.age
    assert_equal 0, @user.gender
  end

  test "accepts the Email model" do
    assert_equal @email, @user_form.email
  end

  test "responds to the Email attributes" do
    attributes = [:address, :address=]

    attributes.each do |attribute|
      assert_respond_to @user_form, attribute
    end
  end

  test "delegates the attributes to Email" do
    @user_form.address = "petrakos@gmail.com"

    assert_equal "petrakos@gmail.com", @email.address
  end

  test "validates itself" do
    @user_form.name = nil
    @user_form.age = nil
    @user_form.gender = nil
    @user_form.address = nil

    assert_not @user_form.valid?
    assert_includes @user_form.errors.messages[:name], "can't be blank"
    assert_includes @user_form.errors.messages[:age], "can't be blank"
    assert_includes @user_form.errors.messages[:gender], "can't be blank"
    assert_includes @user_form.errors.messages[:address], "can't be blank"
  end

  test "validates the models" do
    peter = users(:peter)
    @user_form.name = peter.name
    @user_form.age = 23
    @user_form.gender = 0
    @user_form.address = peter.email.address

    assert_not @user_form.valid?
    assert_includes @user_form.errors.messages[:name], "has already been taken"
    assert_includes @user_form.errors.messages[:address], "has already been taken"
  end

  test "sync models with form input data" do
    params = {
      name: "petrakos",
      age: 23,
      gender: 0,
      address: "petrakos@gmail.com"
    }

    @user_form.submit(params)

    assert_equal params[:name], @user_form.name
    assert_equal params[:gender], @user_form.gender
    assert_equal params[:age], @user_form.age
    assert_equal params[:address], @user_form.address
  end

  test "saves the models with submitted data" do
    params = {
      name: "petrakos",
      age: 23,
      gender: 0,
      address: "petrakos@gmail.com"
    }

    @user_form.submit(params)

    assert_difference('User.count') do
      @user_form.save
    end
    assert_equal @email, @user.email
  end

  test "does not saves the models with invalida submitted data" do
    params = {
      name: "m-peter",
      age: 23,
      gender: 0,
      address: "markoupetr@gmail.com"
    }

    @user_form.submit(params)

    assert_difference('User.count', 0) do
      @user_form.save
    end

    assert_equal 2, @user_form.errors.size
  end
end