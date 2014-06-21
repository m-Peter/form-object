require 'test_helper'

class ProjectFormFixture < AbstractForm
  attribute :name

  association :tasks, records: 2 do
    attribute :name

    association :deliverable do
      attribute :description
    end
  end
end

class MainCollectionFormTest < ActiveSupport::TestCase
  def setup
    @project = Project.new
    @form = ProjectFormFixture.new(@project)
  end

  test "declares collection association" do
    assert_respond_to ProjectFormFixture, :association
  end

  test "contains a forms list for has_many associations" do
    assert_equal 1, ProjectFormFixture.forms.size
  end

  test "main provides getter method for tasks collection form" do
    tasks_form = @form.forms.first

    assert_instance_of FormCollection, tasks_form
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    tasks_form = @form.forms.first

    assert tasks_form.represents?("tasks")
    assert_not tasks_form.represents?("task")
  end

  test "main provides getter method for collection objects" do
    assert_respond_to @form, :tasks

    tasks = @form.tasks

    tasks.each do |form|
      assert_instance_of Form, form
      assert_instance_of Task, form.model
    end
  end

  test "collection sub-form contains association name and parent model" do
    tasks_form = @form.forms.first

    assert_equal :tasks, tasks_form.association_name
    assert_equal 2, tasks_form.records
    assert_equal @project, tasks_form.parent
  end
end
