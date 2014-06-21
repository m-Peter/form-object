require 'test_helper'

class ConferencesControllerTest < ActionController::TestCase
  setup do
    @conference = conferences(:ruby)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:conferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conference" do
    assert_difference('Conference.count') do
      post :create, conference: {
        name: "Euruco",
        city: "Athens",

        speaker_attributes: {
          name: "Petros Markou",
          occupation: "Developer",

          presentations_attributes: {
            "0" => { topic: "Ruby OOP", duration: "1h" },
            "1" => { topic: "Ruby Closures", duration: "1h" },
          }
        }
      }
    end

    conference_form = assigns(:conference_form)

    assert_redirected_to conference_path(conference_form)
    assert_equal "Euruco", conference_form.name
    assert_equal "Athens", conference_form.city
    assert_equal "Petros Markou", conference_form.speaker.name
    assert_equal "Developer", conference_form.speaker.occupation
    assert_equal "Ruby OOP", conference_form.speaker.presentations[0].topic
    assert_equal "1h", conference_form.speaker.presentations[0].duration
    assert_equal "Ruby Closures", conference_form.speaker.presentations[1].topic
    assert_equal "1h", conference_form.speaker.presentations[1].duration
    assert_equal "Conference: #{conference_form.name} was successfully created.", flash[:notice]
  end

  test "should show conference" do
    get :show, id: @conference
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @conference
    assert_response :success
  end

  test "should update conference" do
    patch :update, id: @conference, conference: { city: @conference.city, name: @conference.name }
    assert_redirected_to conference_path(assigns(:conference))
  end

  test "should destroy conference" do
    assert_difference('Conference.count', -1) do
      delete :destroy, id: @conference
    end

    assert_redirected_to conferences_path
  end
end
