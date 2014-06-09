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

end