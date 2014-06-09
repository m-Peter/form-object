require 'test_helper'

class NestedCollectionForm < FormModel
  attribute :name

  validates :name, presence: true
end

class NestedCollectionFormTest < ActiveSupport::TestCase

  test "accepts the model it represents" do
    project = Project.new
    form = NestedCollectionForm.new(project)

    assert_equal project, form.model
  end

end