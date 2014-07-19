require 'test_helper'
require_relative 'project_with_people_fixture'

class ProjectWithPeopleFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @project = Project.new
    @form = ProjectWithPeopleFixture.new(@project)
    @model = @form
  end

  test "responds to contributors" do
    assert_respond_to @form, :contributors
  end

  test "responds to attributes" do
    attributes = [:name, :name=, :owner_id, :owner_id=]

    attributes.each do |attribute|
      assert_respond_to @form, attribute
    end
  end

  test "submits params" do
    peter = Person.create(name: "Peter Markou", role: "Lead Developer",
      description: "Responsible for the architecture")

    params = {
      name: "Praxis Virtual Market",
      owner_id: peter.id,

      contributors_attributes: {
        "0" => { name: "Pieter", role: "Backend Developer", description: "Responsible for the backend functionality" },
        "1" => { name: "Joao", role: "Front-end Developer", description: "Responsible for the front-end display" }
      }
    }

    @form.submit(params)

    assert_equal peter, @form.model.owner
    assert_equal 2, @form.contributors.size
    assert_equal "Pieter", @form.contributors[0].name
    assert_equal "Backend Developer", @form.contributors[0].role
    assert_equal "Responsible for the backend functionality", @form.contributors[0].description
    assert_equal "Joao", @form.contributors[1].name
    assert_equal "Front-end Developer", @form.contributors[1].role
    assert_equal "Responsible for the front-end display", @form.contributors[1].description

    assert_difference('Project.count') do
      @form.save
    end

    @form.contributors.each do |person|
      assert person.persisted?
    end
  end
end