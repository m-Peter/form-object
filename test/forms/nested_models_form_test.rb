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

  test "profile form validates itself" do
    profile_form = @form.profile
    profile_form.twitter_name = nil
    profile_form.github_name = nil

    assert_not profile_form.valid?
  end

  test "main form syncs models in nested forms" do
    params = {
      name: "Petrakos",
      age: "23",
      gender: "0",

      email: {
        address: "petrakos@gmail.com"
      },

      profile: {
        twitter_name: "t_peter",
        github_name: "g_peter"
      }
    }

    @form.submit(params)

    assert_equal "Petrakos", @form.name
    assert_equal 23, @form.age
    assert_equal 0, @form.gender
    assert_equal "petrakos@gmail.com", @form.email.address
    assert_equal "t_peter", @form.profile.twitter_name
    assert_equal "g_peter", @form.profile.github_name
  end

  test "main form saves all the models" do
    params = {
      name: "Petrakos",
      age: "23",
      gender: "0",

      email: {
        address: "petrakos@gmail.com"
      },

      profile: {
        twitter_name: "t_peter",
        github_name: "g_peter"
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
    assert_equal "t_peter", @form.profile.twitter_name
    assert_equal "g_peter", @form.profile.github_name
    
    assert @form.persisted?
    assert @form.email.persisted?
    assert @form.profile.persisted?
  end
end