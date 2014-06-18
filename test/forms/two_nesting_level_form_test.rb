require 'test_helper'
require_relative 'two_nesting_level_form'

class TwoNestingLevelFormTest < ActiveSupport::TestCase
  def setup
    @song = Song.new
    @form = TwoNestingLevelForm.new(@song)
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

  test "producer sub-form initializes models for new parent" do
    producer_form = @form.artist.producer

    assert_equal @form.artist.model.producer, @form.artist.producer.model
    assert @form.artist.producer.model.new_record?
  end

  test "producer sub-form fetches models for existing parent" do
    song = songs(:lockdown)
    form = TwoNestingLevelForm.new(song)
    artist_form = form.artist
    producer_form = artist_form.producer

    assert_equal "Love Lockdown", form.title
    assert_equal "350", form.length
    assert form.persisted?

    assert_equal "Kanye West", artist_form.name
    assert artist_form.persisted?

    assert_equal "Jay-Z", producer_form.name
    assert_equal "Ztudio", producer_form.studio
    assert producer_form.persisted?
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

  test "main form validates itself" do
    @form.title = nil
    @form.length = nil

    assert_not @form.valid?

    @form.title = "Diamonds"
    @form.length = "355"

    assert @form.valid?
  end

  test "main form saves all the models" do
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

    assert_difference(['Song.count', 'Artist.count', 'Producer.count']) do
      @form.save
    end

    assert_equal "Diamonds", @form.title
    assert_equal "360", @form.length
    assert_equal "Karras", @form.artist.name
    assert_equal "Phoebos", @form.artist.producer.name
    assert_equal "MADog", @form.artist.producer.studio

    assert @form.persisted?
    assert @form.artist.persisted?
    assert @form.artist.producer.persisted?
  end

  test "main form updates all the models" do
    song = songs(:lockdown)
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
    form = TwoNestingLevelForm.new(song)

    form.submit(params)

    assert_difference(['Song.count', 'Artist.count', 'Producer.count'], 0) do
      form.save
    end

    assert_equal "Diamonds", form.title
    assert_equal "360", form.length
    assert_equal "Karras", form.artist.name
    assert_equal "Phoebos", form.artist.producer.name
    assert_equal "MADog", form.artist.producer.studio

    assert form.persisted?
    assert form.artist.persisted?
    assert form.artist.producer.persisted?
  end

end