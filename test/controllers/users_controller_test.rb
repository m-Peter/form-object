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
    assert_difference(['User.count', 'Email.count']) do
      post :create, user: {
        age: "23",
        gender: "0",
        name: "petrakos",
        email: {
          address: "petrakos@gmail.com"  
        }
      }
    end

    main_form = assigns(:main_form)

    assert_redirected_to user_path(main_form)
    assert_equal "petrakos", main_form.name
    assert_equal 23, main_form.age
    assert_equal 0, main_form.gender
    assert_equal "petrakos@gmail.com", main_form.email.address
    assert_equal "User: #{main_form.name} was successfully created.", flash[:notice]
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
      email: {
        address: "petrakos@gmail.com"
      }
    }

    main_form = assigns(:main_form)

    assert_redirected_to user_path(main_form)
    assert_equal "petrakos", main_form.name
    assert_equal "petrakos@gmail.com", main_form.email.address
    assert_equal "User: #{main_form.name} was successfully updated.", flash[:notice]
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
