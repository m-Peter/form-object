require 'test_helper'
require_relative 'nested_model_form'

class NestedModelFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @user = User.new
    @form = NestedModelForm.new(@user)
    @model = @form
  end

  test "declares association" do
    assert_respond_to NestedModelForm, :association
  end

  test "contains a list of sub-forms" do
    assert_respond_to NestedModelForm, :forms
  end

  test "forms list contains form definitions" do
    email_definition = NestedModelForm.forms.first

    assert_equal :email, email_definition[:assoc_name]
  end

  test "sub-forms contains association name and parent model" do
    email_form = @form.email

    assert_equal :email, email_form.association_name
    assert_equal @user, email_form.parent
  end

  test "contains getter for sub-form" do
    assert_respond_to @form, :email
    assert_instance_of Form, @form.email
  end

  test "sub-form initializes model for new parent" do
    email_form = @form.email

    assert_instance_of Email, email_form.model
    assert_equal @form.model.email, email_form.model
    assert email_form.model.new_record?
  end

  test "sub-form fetches model for existing parent" do
    user = users(:peter)
    user_form = NestedModelForm.new(user)
    email_form = user_form.email

    assert_instance_of Email, email_form.model
    assert_equal user_form.model.email, email_form.model
    assert email_form.model.persisted?
    assert_equal "m-peter", user_form.name
    assert_equal 23, user_form.age
    assert_equal 0, user_form.gender
    assert_equal "markoupetr@gmail.com", email_form.model.address
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    email_form = @form.email

    assert email_form.represents?("email")
    assert_not email_form.represents?("profile")
  end

  test "sub-form declares attributes" do
    email_form = @form.email
    attributes = [:address, :address=]

    attributes.each do |attribute|
      assert_respond_to email_form, attribute
    end
  end

  test "sub-form delegates attributes to model" do
    email_form = @form.email
    email_form.address = "petrakos@gmail.com"

    assert_equal "petrakos@gmail.com", email_form.address
    assert_equal "petrakos@gmail.com", email_form.model.address
  end

  test "sub-form validates itself" do
    email_form = @form.email
    email_form.address = nil

    assert_not email_form.valid?
    assert_includes email_form.errors.messages[:address], "can't be blank"

    email_form.address = "petrakos@gmail.com"

    assert email_form.valid?
  end

  test "sub-form validates the model" do
    existing_email = emails(:peters)
    email_form = @form.email
    email_form.address = existing_email.address
    
    assert_not email_form.valid?
    assert_includes email_form.errors.messages[:address], "has already been taken"

    email_form.address = "petrakos@gmail.com"

    assert email_form.valid?
  end

  test "main form syncs models in sub-forms" do
    params = {
      name: "Petrakos",
      age: "23",
      gender: "0",

      email_attributes: {
        address: "petrakos@gmail.com"
      }
    }

    @form.submit(params)

    assert_equal "Petrakos", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
    assert_equal "petrakos@gmail.com", @form.email.address
  end

  test "main form saves all the models" do
    params = {
      name: "Petrakos",
      age: "23",
      gender: "0",

      email_attributes: {
        address: "petrakos@gmail.com"
      }
    }

    @form.submit(params)

    assert_difference(['User.count', 'Email.count']) do
      @form.save
    end

    assert_equal "Petrakos", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
    assert_equal "petrakos@gmail.com", @form.email.address
    
    assert @form.persisted?
    assert @form.email.persisted?
  end

  test "main form collects all the errors" do
    peter = users(:peter)
    params = {
      name: peter.name,
      age: "23",
      gender: "0",
      
      email_attributes: {
        address: peter.email.address
      }
    }

    @form.submit(params)

    assert_difference(['User.count', 'Email.count'], 0) do
      @form.save
    end

    assert_includes @form.errors.messages[:name], "has already been taken"
    assert_includes @form.errors.messages[:address], "has already been taken"
  end
end