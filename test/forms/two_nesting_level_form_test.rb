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
  def setup
    @song = Song.new
    @form = SongForm.new(@song)
  end

  test "Form declares association" do
    assert_respond_to Form, :association
  end

  test "Form contains a list of sub-forms" do
    assert_respond_to Form, :forms
  end

  test "forms list contains form definitions" do
    producer_definition = Form.forms.first

    assert_equal :producer, producer_definition.assoc_name
  end

  test "contains getter for producer sub-form" do
    assert_respond_to @form.artist, :producer
    assert_instance_of Form, @form.artist.producer
  end

  test "producer sub-form contains association name and parent model" do
    producer_form = @form.artist.producer

    assert_equal :producer, producer_form.association_name
    assert_instance_of Producer, producer_form.model
    assert_instance_of Artist, producer_form.parent
  end

  test "producer sub-form initializes model for new parent" do
    producer_form = @form.artist.producer

    assert_equal @form.artist.model.producer, @form.artist.producer.model
    assert @form.artist.producer.model.new_record?
  end

  test "producer sub-form declares attributes" do
    attributes = [:name, :name=, :studio, :studio=]

    attributes.each do |attribute|
      assert_respond_to @form.artist.producer, attribute
    end
  end

  test "producer sub-form delegates attributes to model" do
    producer_form = @form.artist.producer
    producer_form.name = "Phoebos"
    producer_form.studio = "MADog"

    assert_equal "Phoebos", producer_form.name
    assert_equal "MADog", producer_form.studio

    assert_equal "Phoebos", producer_form.model.name
    assert_equal "MADog", producer_form.model.studio
  end

  test "main form syncs model in producer sub-form" do
    params = {
      title: "Diamonds",
      length: "360",

      artist_attributes: {
        name: "Karras",

        producer_attributes: {
          name: "Phoebos",
          studio: "MADog"
        }
      }
    }

    @form.submit(params)

    assert_equal "Diamonds", @form.title
    assert_equal "360", @form.length
    assert_equal "Karras", @form.artist.name
    assert_equal "Phoebos", @form.artist.producer.name
    assert_equal "MADog", @form.artist.producer.studio
  end

end