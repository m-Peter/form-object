require 'test_helper'
require_relative 'nested_models_form'

class NestedModelsFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @user = User.new
    @form = NestedModelsForm.new(@user)
    @model = @form
  end

  test "declares both sub-forms" do
    profile_definition = NestedModelsForm.forms.last

    assert_equal 2, NestedModelsForm.forms.size
    assert_equal :profile, profile_definition[:assoc_name]

    profile_form = @form.profile

    assert_equal 2, @form.forms.size
    assert_equal :profile, profile_form.association_name
    assert_equal @user, profile_form.parent
  end

  test "profile form declares attributes" do
    attributes = [:twitter_name, :twitter_name=, :github_name, :github_name=]
    profile_form = @form.profile

    attributes.each do |attribute|
      assert_respond_to profile_form, attribute
    end
  end

  test "profile form delegates attributes to model" do
    profile_form = @form.profile
    profile_form.twitter_name = "twitter_peter"
    profile_form.github_name = "github_peter"

    assert_equal "twitter_peter", profile_form.twitter_name
    assert_equal "github_peter", profile_form.github_name
  end

  test "profile form initializes model for new parent" do
    profile_form = @form.profile

    assert_instance_of Profile, profile_form.model
    assert_equal @form.model.profile, profile_form.model
    assert profile_form.model.new_record?
  end

  test "profile form fetches model for existing parent" do
    user = users(:peter)
    user_form = NestedModelsForm.new(user)
    profile_form = user_form.profile

    assert_instance_of Profile, profile_form.model
    assert_equal user_form.model.profile, profile_form.model
    assert profile_form.model.persisted?
    assert_equal "m-peter", user_form.name
    assert_equal 23, user_form.age
    assert_equal 0, user_form.gender
    assert_equal "twitter_peter", profile_form.model.twitter_name
    assert_equal "github_peter", profile_form.model.github_name
  end
end