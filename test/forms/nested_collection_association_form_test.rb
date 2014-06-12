require 'test_helper'

class NestedCollectionAssociationForm < AbstractForm
  attribute :name

  association :tasks, records: 3 do
    attribute :name

    validates :name, presence: true
  end

  validates :name, presence: true
end

class NestedCollectionAssociationFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @project = Project.new
    @form = NestedCollectionAssociationForm.new(@project)
    @model = @form
  end

  test "declare collection association" do
    assert_respond_to NestedCollectionAssociationForm, :association
  end

  test "contains a collections Array for has_many associations" do
    assert_respond_to NestedCollectionAssociationForm, :collections
    assert_instance_of Array, NestedCollectionAssociationForm.collections
    assert_equal 1, NestedCollectionAssociationForm.collections.size
  end

  test "collections Array contains form definitions" do
    tasks_definition = NestedCollectionAssociationForm.collections.first

    assert_equal :tasks, tasks_definition[:assoc_name]
    assert_equal 3, tasks_definition[:records]
    assert_not_nil tasks_definition[:proc]
  end

  test "provides getter method for collection" do
    tasks_form = @form.collections.first

    assert_instance_of FormCollection, tasks_form
  end

  test "provides getter method for collection objects" do
    assert_respond_to @form, :tasks

    tasks = @form.tasks

    tasks.each do |form|
      assert_instance_of Form, form
      assert_instance_of Task, form.model
    end
  end

  test "collection form contains association name and parent model" do
    tasks_form = @form.collections.first

    assert_equal :tasks, tasks_form.association_name
    assert_equal 3, tasks_form.records
    assert_equal @project, tasks_form.parent
  end

  test "collection form initializes the number of records specified" do
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

  test "collection form fetches parent and association objects" do
    project = projects(:yard)

    form = NestedCollectionAssociationForm.new(project)

    assert_equal project.name, form.name
    assert_equal 3, form.tasks.size
    assert_equal project.tasks[0], form.tasks[0].model
    assert_equal project.tasks[1], form.tasks[1].model
    assert_equal project.tasks[2], form.tasks[2].model
  end

  test "collection form sync models with submitted params" do
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

  test "collection validates itself" do
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

  test "collection form saves all the models" do
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

  test "collection form updates all the models" do
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