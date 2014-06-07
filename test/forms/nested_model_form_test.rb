require 'test_helper'
require_relative 'nested_model_form'

class NestedModelFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @user = User.new
    @form = NestedModelForm.new(@user)
    @model = @form
  end

  test "declare association" do
    assert_respond_to NestedModelForm, :association
  end

  test "maintains a collection of sub-forms" do
    assert_respond_to NestedModelForm, :forms
  end

  test "forms collection contains form definitions" do
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
    assert_instance_of SubForm, @form.email
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
end