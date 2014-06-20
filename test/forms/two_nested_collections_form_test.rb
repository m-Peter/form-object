require 'test_helper'

class SurveyForm < AbstractForm
  attribute :name

  association :questions, records: 2 do
    attribute :content
  end
end

class TwoNestedCollectionsFormTest < ActiveSupport::TestCase
  def setup
    @survey = Survey.new
    @form = SurveyForm.new(@survey)
  end

  test "declares collection association" do
    assert_respond_to SurveyForm, :association
  end

  test "contains a forms list for has_many associations" do
    assert_equal 1, SurveyForm.forms.size
  end

  test "main provides getter method for collection form" do
    questions_form = @form.forms.first

    assert_instance_of FormCollection, questions_form
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    questions_form = @form.forms.first

    assert questions_form.represents?("questions")
    assert_not questions_form.represents?("question")
  end

  test "main provides getter method for collection objects" do
    assert_respond_to @form, :questions

    questions = @form.questions

    questions.each do |form|
      assert_instance_of Form, form
      assert_instance_of Question, form.model
    end
  end

  test "collection sub-form contains association name and parent model" do
    questions_form = @form.forms.first

    assert_equal :questions, questions_form.association_name
    assert_equal 2, questions_form.records
    assert_equal @survey, questions_form.parent
  end

  test "collection sub-form initializes the number of records specified" do
    questions_form = @form.forms.first

    assert_respond_to questions_form, :models
    assert_equal 2, questions_form.models.size
    
    questions_form.each do |form|
      assert_instance_of Form, form
      assert_instance_of Question, form.model
      assert_respond_to form, :content
      assert_respond_to form, :content=
    end

    assert_equal 2, @form.model.questions.size
  end

  test "collection sub-form fetches parent and association objects" do
    survey = surveys(:programming)

    form = SurveyForm.new(survey)

    assert_equal survey.name, form.name
    assert_equal 2, form.questions.size
    assert_equal survey.questions[0], form.questions[0].model
    assert_equal survey.questions[1], form.questions[1].model
  end

  test "collection sub-form syncs models with submitted params" do
    params = {
      name: "Programming languages",
      questions_attributes: {
        "0" => { content: "Which language allows closures?" },
        "1" => { content: "Which language allows objects?" },
      }
    }

    @form.submit(params)

    assert_equal "Programming languages", @form.name
    assert_equal "Which language allows closures?", @form.questions[0].content
    assert_equal "Which language allows objects?", @form.questions[1].content
    assert_equal 2, @form.questions.size
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :questions_attributes=
  end
end