require 'test_helper'

class ProductFormTest < ActiveSupport::TestCase

  def setup
    @product = Product.new
    @product_form = ProductForm.new(@product)
  end

  test "form object accepts the model it represents" do
    assert_instance_of Product, @product_form.model
  end

  test "form object delegates attributes in the main model" do
    @product_form.title = "iPhone 5S"
    assert_equal @product_form.title, @product.title

    @product_form.price = 399.90
    assert_equal @product_form.price, @product.price
  end

  test "form object responds to persisted?" do
    assert_not @product_form.persisted?

    product_form = ProductForm.new(products(:one))
    assert product_form.persisted?
  end

  test "form object responds to to_key" do
    assert_nil @product_form.to_key

    product_form = ProductForm.new(products(:one))
    assert_equal products(:one).id, product_form.to_key
  end

  test "form object responds to to_param" do
    assert_nil @product_form.to_param

    product_form = ProductForm.new(products(:one))
    assert_equal products(:one).id.to_s, product_form.to_param
  end

  test "form object responds to to_partial_path" do
    assert_equal "", @product_form.to_partial_path
  end

  test "form object responds to to_model" do
    assert_equal @product, @product_form.to_model
  end

  test "form object can save the model" do
    params = {
      title: "Nexus 4S",
      description: "Smartphone by Google.",
      price: 500.49,
      units: 10
    }

    assert_difference("Product.count", +1) {
      @product_form.save(params)
    }

    assert_equal @product_form.model.title, params[:title]
    assert_equal @product_form.model.description, params[:description]
    assert_equal @product_form.model.price, params[:price]
    assert_equal @product_form.model.units, params[:units]
  end

  test "form object can update the model" do
    product = products(:phone)
    product_form = ProductForm.new(product)

    params = {
      price: 699.50,
      units: 2
    }

    assert_difference "Product.count", 0 do
      product_form.save(params)
    end

    assert_equal product_form.model.price, params[:price]
    assert_equal product_form.model.units, params[:units]
    assert_equal product_form.model.title, product.title
    assert_equal product_form.model.description, product.description
  end
end