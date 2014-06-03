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
  end
end