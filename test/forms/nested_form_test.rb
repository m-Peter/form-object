require 'test_helper'

class FormModel
  include ActiveModel::Model
  
  attr_reader :model, :forms

  def initialize(model)
    @model = model
    @forms = []
    populate_forms
  end

  def populate_forms
    self.class.forms.each do |definition|
      definition[:parent] = model
      sub_form = SubForm.new(definition)
      @forms << sub_form
      instance_variable_set("@#{definition[:assoc_name]}", sub_form)
    end
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

  class << self
    def attributes(*names)
      names.each do |attribute|
        delegate attribute, to: :model
        delegate "#{attribute}=", to: :model
      end
    end

    def association(name)
      forms << {assoc_name: name}
      attr_reader name
    end

    def forms
      @@forms ||= []
    end
  end
end

class SubForm
  attr_reader :association_name
  attr_reader :parent
  attr_reader :model

  def initialize(args)
    @association_name = args[:assoc_name]
    @parent = args[:parent]
    @model = build_model
  end

  def build_model
    if @parent.send("#{@association_name}")
      @model = @parent.send("#{@association_name}")
    else
      model_class = @association_name.to_s.camelize.constantize
      @model = model_class.new
      @parent.send("#{@association_name}=", @model)
    end
  end
end

class UserFormFixture < FormModel
  attributes :name, :age, :gender

  association :email

  validates :name, :age, :gender, presence: true
  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }
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

  test "declare association" do
    assert_respond_to UserFormFixture, :association
  end

  test "maintains a collection of sub-forms" do
    assert_respond_to UserFormFixture, :forms
  end

  test "forms collection contains form definitions" do
    email_definition = UserFormFixture.forms.first

    assert_equal :email, email_definition[:assoc_name]
  end

  test "sub-forms contains association name" do
    email_form = @user_form.forms.first

    assert_equal :email, email_form.association_name
    assert_equal @user, email_form.parent
  end

  test "contains getter for sub-form" do
    assert_respond_to @user_form, :email
    assert_instance_of SubForm, @user_form.email
  end

  test "sub-form initializes model for new parent" do
    user = User.new
    user_form = UserFormFixture.new(user)
    email_form = user_form.email

    assert_instance_of Email, email_form.model
    assert_equal user_form.model.email, email_form.model
    assert email_form.model.new_record?
  end

  test "sub-form fetches model for existing parent" do
    user = users(:peter)
    user_form = UserFormFixture.new(user)
    email_form = user_form.email

    assert_instance_of Email, email_form.model
    assert_equal user_form.model.email, email_form.model
    assert email_form.model.persisted?
    assert_equal "markoupetr@gmail.com", email_form.model.address
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