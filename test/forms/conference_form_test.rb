require 'test_helper'

class ConferenceForm < AbstractForm
  attributes :name, :city

  association :speaker do
    attribute :name, :occupation

    association :presentations, records: 2 do
      attribute :topic, :duration
    end
  end
end

class ConferenceFormTest < ActiveSupport::TestCase
  def setup
    @conference = Conference.new
    @form = ConferenceForm.new(@conference)
  end

  test "Form declares association" do
    assert_respond_to Form, :association
  end

  test "Form contains a list of sub-forms" do
    assert_respond_to Form, :forms
    assert_equal 1, Form.forms.size
  end

  test "forms list contains form definitions" do
    producer_definition = Form.forms.first

    assert_equal :presentations, producer_definition.assoc_name
  end
end