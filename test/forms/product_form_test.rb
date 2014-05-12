require 'test_helper'

class ProductFormTest < ActiveSupport::TestCase
  test "product form accepts the model it represents" do
    product_form = ProductForm.new(Product.new)

    assert_instance_of Product, product_form.model
  end

  test "delegates attributes in the main model" do
    product = Product.new
    product_form = ProductForm.new(product)

    product_form.title = "iPhone 5S"
    assert_equal product_form.title, product.title

    product_form.price = 399.90
    assert_equal product_form.price, product.price
  end

  test "product form responds to persisted?" do
    product = Product.new
    product_form = ProductForm.new(product)

    assert_not product_form.persisted?

    product_form = ProductForm.new(products(:one))
    assert product_form.persisted?
  end

  test "product form responds to to_key" do
    product = Product.new
    product_form = ProductForm.new(product)

    assert_nil product_form.to_key

    product_form = ProductForm.new(products(:one))
    assert_equal products(:one).id, product_form.to_key
  end

  test "product form responds to to_param" do
    product = Product.new
    product_form = ProductForm.new(product)

    assert_nil product_form.to_param

    product_form = ProductForm.new(products(:one))
    assert_equal products(:one).id.to_s, product_form.to_param
  end

  test "product form responds to to_partial_path" do
    product = Product.new
    product_form = ProductForm.new(product)

    assert_equal "", product_form.to_partial_path
  end

  test "product form responds to model_name" do
    product = Product.new
    product_form = ProductForm.new(product)

    assert_equal "Product", ProductForm.model_name.name
  end
end