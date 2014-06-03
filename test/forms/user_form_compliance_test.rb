require 'test_helper'

class UserFormComplianceTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @user = User.new
    @email = Email.new
    @model = UserForm.new(@user, @email)
  end

  test "responds to #persisted?" do
    assert_not @model.persisted?
    
    save_model

    assert @model.persisted?
  end

  test "responds to #to_key" do
    assert_nil @model.to_key
    assert_not @model.persisted?
    
    save_model

    assert_equal @user.id, @model.to_key
  end

  test "responds to #to_param" do
    assert_nil @model.to_param
    assert_not @model.persisted?
    
    assert_equal @user.to_param, @model.to_param
  end

  test "responds to #to_model" do
    assert_equal @user, @model.to_model
  end

  test "responds to .model_name" do
    assert_equal User.model_name, UserForm.model_name
  end

  private

  def save_model()
    params = {
      name: "petrakos",
      age: 23,
      gender: 0,
      address: "petrakos@gmail.com"
    }

    @model.submit(params)
    @model.save
  end
end