require 'test_helper'

class SongForm < AbstractForm
  attributes :title, :length

  association :artist do
    attribute :name

    association :producer do
      attributes :name, :studio
    end
  end
end

class TwoNestingLevelFormTest < ActiveSupport::TestCase
  test "Form declares association" do
    assert_respond_to Form, :association
  end

end