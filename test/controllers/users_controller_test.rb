require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:peter)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: {
        age: "23",
        gender: "0",
        name: "petrakos",
        address: "petrakos@gmail.com"
      }
    end

    user_form = assigns(:user_form)

    assert_redirected_to user_path(user_form)
    assert_equal "petrakos", user_form.name
    assert_equal 23, user_form.age
    assert_equal 0, user_form.gender
    assert_equal "petrakos@gmail.com", user_form.address
    assert_equal "User: #{user_form.name} was successfully created.", flash[:notice]
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: {
      age: @user.age,
      gender: @user.gender,
      name: "petrakos",
      address: "petrakos@gmail.com"
    }

    user_form = assigns(:user_form)

    assert_redirected_to user_path(user_form)
    assert_equal "petrakos", user_form.name
    assert_equal "petrakos@gmail.com", user_form.address
    assert_equal "User: #{user_form.name} was successfully updated.", flash[:notice]
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
