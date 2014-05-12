require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product" do
    assert_difference('Product.count') do
      post :create, :product => {
        description: "A smartphone by Google Inc.",
        price: 459.50,
        title: "Nexus 4S",
        units: 3
      }
    end

    product_form = assigns(:product_form)

    assert_not_nil product_form
    assert_kind_of ProductForm, product_form
    assert_equal "Product was successfully created.", flash[:notice]

    assert_redirected_to product_path(product_form)
  end

  test "should show product" do
    get :show, id: @product
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product
    assert_response :success
  end

  test "should update product" do
    product = products(:phone)

    assert_difference('Product.count', 0) do
      patch :update, id: product.id, :product => {
        description: product.description,
        price: product.price,
        title: product.title,
        units: 4
      }
    end

    product_form = assigns(:product_form)

    assert_not_nil product_form
    assert_kind_of ProductForm, product_form
    assert_equal "Product was successfully updated.", flash[:notice]
    assert_redirected_to product_path(product_form)
  end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete :destroy, id: @product
    end

    assert_redirected_to products_path
  end
end
