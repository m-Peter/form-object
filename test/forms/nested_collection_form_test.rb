require 'test_helper'

class NestedCollectionForm < FormModel
  attribute :name

  collection :tasks, records: 3 do
    attribute :name

    validates :name, presence: true
  end

  validates :name, presence: true
end

class NestedCollectionFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @project = Project.new
    @form = NestedCollectionForm.new(@project)
    @model = @form
  end

  test "declare collection" do
    assert_respond_to NestedCollectionForm, :collection
  end

  test "contains a collections Array for has_many associations" do
    assert_respond_to NestedCollectionForm, :collections
    assert_instance_of Array, NestedCollectionForm.collections
  end

  test "collections Array contains form definitions" do
    task_definition = NestedCollectionForm.collections.first

    assert_equal :tasks, task_definition[:assoc_name]
    assert_equal 3, task_definition[:records]
    assert_not_nil task_definition[:proc]
  end

  test "contains getter for collection" do
    tasks_form = @form.collections.first

    assert_respond_to @form, :tasks
    assert_instance_of CollectionForm, tasks_form
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
      assert_instance_of SubForm, form
      assert_instance_of Task, form.model
      assert_respond_to form, :name
      assert_respond_to form, :name=
    end

    assert_equal 3, @form.model.tasks.size
  end

  test "collection form fetches parent and association objects" do
    project = projects(:yard)

    form = NestedCollectionForm.new(project)

    assert_equal "Yard Work", form.name
    assert_equal 3, form.tasks.size
    assert_equal "rake the leaves", form.tasks[0].name
    assert_equal "paint the fence", form.tasks[1].name
    assert_equal "clean the gutters", form.tasks[2].name
  end

  test "main form responds to to writer method" do
    assert_respond_to @form, :tasks_attributes=
  end

end