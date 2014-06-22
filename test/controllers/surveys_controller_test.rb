require 'test_helper'

class SurveysControllerTest < ActionController::TestCase
  setup do
    @survey = surveys(:programming)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:surveys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey" do
    assert_difference('Survey.count') do
      post :create, survey: {
        name: "Programming languages",

        questions_attributes: {
          "0" => {
            content: "Which language allows closures?",

            answers_attributes: {
              "0" => { content: "Ruby Programming Language" },
              "1" => { content: "CSharp Programming Language" },
            }
          }
        }
      }
    end

    survey_form = assigns(:survey_form)

    assert_redirected_to survey_path(assigns(:survey_form))
    assert_equal "Programming languages", survey_form.name
    assert_equal "Which language allows closures?", survey_form.questions[0].content
    assert_equal "Ruby Programming Language", survey_form.questions[0].answers[0].content
    assert_equal "CSharp Programming Language", survey_form.questions[0].answers[1].content
    assert_equal "Survey: #{survey_form.name} was successfully created.", flash[:notice]
  end

  test "should show survey" do
    get :show, id: @survey
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @survey
    assert_response :success
  end

  test "should update survey" do
    patch :update, id: @survey, survey: { name: @survey.name }
    assert_redirected_to survey_path(assigns(:survey))
  end

  test "should destroy survey" do
    assert_difference('Survey.count', -1) do
      delete :destroy, id: @survey
    end

    assert_redirected_to surveys_path
  end
end
