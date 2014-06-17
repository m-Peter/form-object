require 'test_helper'
require_relative 'nested_collection_association_form'

class NestedCollectionAssociationFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @project = Project.new
    @form = NestedCollectionAssociationForm.new(@project)
    @model = @form
  end

  test "declares collection association" do
    assert_respond_to NestedCollectionAssociationForm, :association
  end

  test "contains a collections list for has_many associations" do
    assert_respond_to NestedCollectionAssociationForm, :collections
    assert_instance_of Array, NestedCollectionAssociationForm.collections
    assert_equal 1, NestedCollectionAssociationForm.collections.size
  end

  test "contains a definitions list for has_many associations" do
    assert_respond_to NestedCollectionAssociationForm, :definitions
  end

  test "definitions list contains form definitions for has_many associations" do
    tasks_definition = NestedCollectionAssociationForm.definitions.first
    tasks_definition.parent = @project

    assert_equal :tasks, tasks_definition.assoc_name
    assert_equal @project, tasks_definition.parent
    assert_equal 3, tasks_definition.records
    assert_not_nil tasks_definition.proc
  end

  test "FormDefinition creates FormCollection from arguments" do
    tasks_definition = NestedCollectionAssociationForm.definitions.first
    tasks_definition.parent = @project
    tasks_form = tasks_definition.to_form

    assert_instance_of FormCollection, tasks_form
    assert_equal :tasks, tasks_form.association_name
    assert_equal @project, tasks_form.parent
    assert_equal 3, tasks_form.records
  end

  test "main form initializes FormCollections from definitions list" do
    @form.init_definitions

    assert_equal 1, @form.definitions.size

    tasks_form = @form.definitions.first

    assert_instance_of FormCollection, tasks_form
    assert_equal :tasks, tasks_form.association_name
    assert_equal @project, tasks_form.parent
  end

  test "collections list contains form definitions" do
    tasks_definition = NestedCollectionAssociationForm.collections.first

    assert_equal :tasks, tasks_definition[:assoc_name]
    assert_equal 3, tasks_definition[:records]
    assert_not_nil tasks_definition[:proc]
  end

  test "main provides getter method for collection" do
    tasks_form = @form.collections.first

    assert_instance_of FormCollection, tasks_form
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    tasks_form = @form.collections.first

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
    tasks_form = @form.collections.first

    assert_equal :tasks, tasks_form.association_name
    assert_equal 3, tasks_form.records
    assert_equal @project, tasks_form.parent
  end

  test "collection sub-form initializes the number of records specified" do
    tasks_form = @form.collections.first

    assert_respond_to tasks_form, :models
    assert_equal 3, tasks_form.models.size
    
    tasks_form.each do |form|
      assert_instance_of Form, form
      assert_instance_of Task, form.model
      assert_respond_to form, :name
      assert_respond_to form, :name=
    end

    assert_equal 3, @form.model.tasks.size
  end

  test "collection sub-form fetches parent and association objects" do
    project = projects(:yard)

    form = NestedCollectionAssociationForm.new(project)

    assert_equal project.name, form.name
    assert_equal 3, form.tasks.size
    assert_equal project.tasks[0], form.tasks[0].model
    assert_equal project.tasks[1], form.tasks[1].model
    assert_equal project.tasks[2], form.tasks[2].model
  end

  test "collection sub-form syncs models with submitted params" do
    params = {
      name: "Life",
      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" }
      }
    }

    @form.submit(params)

    assert_equal "Life", @form.name
    assert_equal "Eat", @form.tasks[0].name
    assert_equal "Pray", @form.tasks[1].name
    assert_equal "Love", @form.tasks[2].name
    assert_equal 3, @form.tasks.size
  end

  test "collection sub-form validates itself" do
    params = {
      name: "Life",
      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" }
      }
    }

    @form.submit(params)

    assert @form.valid?

    params = {
      name: "Life",
      tasks_attributes: {
        "0" => { name: nil },
        "1" => { name: nil },
        "2" => { name: nil }
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "can't be blank"
    assert_equal 3, @form.errors.messages[:name].size
  end

  test "collection sub-form raises error if records exceed the allowed number" do
    params = {
      name: "Life",
      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" },
        "3" => { name: "Dummy" }
      }
    }

    exception = assert_raises(TooManyRecords) { @form.submit(params) }
    assert_equal "Maximum 3 records are allowed. Got 4 records instead.", exception.message
  end

  test "collection sub-form saves all the models" do
    params = {
      name: "Life",
      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" }
      }
    }

    @form.submit(params)

    assert_difference('Project.count') do
      @form.save
    end

    assert_equal "Life", @form.name
    assert_equal "Eat", @form.tasks[0].name
    assert_equal "Pray", @form.tasks[1].name
    assert_equal "Love", @form.tasks[2].name
    assert_equal 3, @form.tasks.size

    assert @form.persisted?
    @form.tasks.each do |task|
      assert task.persisted?
    end
  end

  test "collection sub-form updates all the models" do
    project = projects(:yard)
    form = NestedCollectionAssociationForm.new(project)
    params = {
      name: "Life",
      tasks_attributes: {
        "0" => { name: "Eat", id: tasks(:rake).id },
        "1" => { name: "Pray", id: tasks(:paint).id },
        "2" => { name: "Love", id: tasks(:clean).id }
      }
    }

    form.submit(params)

    assert_difference('Project.count', 0) do
      form.save
    end

    assert_equal "Life", form.name
    assert_equal "Eat", form.tasks[0].name
    assert_equal "Pray", form.tasks[1].name
    assert_equal "Love", form.tasks[2].name
    assert_equal 3, form.tasks.size
    
    assert form.persisted?
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :tasks_attributes=
  end
end