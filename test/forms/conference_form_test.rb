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

  test "contains getter for presentations sub-form" do
    assert_respond_to @form.speaker, :presentations

    presentations_form = @form.speaker.forms.first
    assert_instance_of FormCollection, presentations_form
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    presentations_form = @form.speaker.forms.first

    assert presentations_form.represents?("presentations")
    assert_not presentations_form.represents?("presentation")
  end

  test "main provides getter method for collection objects" do
    assert_respond_to @form.speaker, :presentations

    presentations = @form.speaker.presentations

    presentations.each do |form|
      assert_instance_of Form, form
      assert_instance_of Presentation, form.model
    end
  end

  test "collection sub-form contains association name and parent model" do
    presentations_form = @form.speaker.forms.first

    assert_equal :presentations, presentations_form.association_name
    assert_equal 2, presentations_form.records
    assert_equal @form.speaker.model, presentations_form.parent
  end

  test "collection sub-form initializes the number of records specified" do
    presentations_form = @form.speaker.forms.first

    assert_respond_to presentations_form, :models
    assert_equal 2, presentations_form.models.size
    
    presentations_form.each do |form|
      assert_instance_of Form, form
      assert_instance_of Presentation, form.model
      assert_respond_to form, :topic
      assert_respond_to form, :topic=
      assert_respond_to form, :duration
      assert_respond_to form, :duration=
    end

    assert_equal 2, @form.speaker.model.presentations.size
  end

  test "collection sub-form fetches parent and association objects" do
    conference = conferences(:ruby)

    form = ConferenceForm.new(conference)

    assert_equal conference.name, form.name
    assert_equal 2, form.speaker.presentations.size
    assert_equal conference.speaker.presentations[0], form.speaker.presentations[0].model
    assert_equal conference.speaker.presentations[1], form.speaker.presentations[1].model
  end

  test "collection sub-form syncs models with submitted params" do
    params = {
      name: "Euruco",
      city: "Athens",

      speaker_attributes: {
        name: "Peter Markou",
        occupation: "Developer",

        presentations_attributes: {
          "0" => { topic: "Ruby OOP", duration: "1h" },
          "1" => { topic: "Ruby Closures", duration: "1h" },
        }
      }
    }

    @form.submit(params)

    assert_equal "Euruco", @form.name
    assert_equal "Athens", @form.city
    assert_equal "Peter Markou", @form.speaker.name
    assert_equal "Developer", @form.speaker.occupation
    assert_equal "Ruby OOP", @form.speaker.presentations[0].topic
    assert_equal "1h", @form.speaker.presentations[0].duration
    assert_equal "Ruby Closures", @form.speaker.presentations[1].topic
    assert_equal "1h", @form.speaker.presentations[1].duration
    assert_equal 2, @form.speaker.presentations.size
  end
end