require 'test_helper'
require_relative 'single_model_form'

class SingleModelFormTest < ActiveSupport::TestCase
  test "accepts the model it represents" do
    user = User.new
    form = SingleModelForm.new(user)

    assert_equal user, form.model
  end
end