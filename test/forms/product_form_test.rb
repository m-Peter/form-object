require 'test_helper'

class ProductFormTest < ActiveSupport::TestCase

  def setup
    @product = Product.new
    @product_form = ProductForm.new(@product)
  end

  test "product form accepts the model it represents" do
    assert_instance_of Product, @product_form.model
  end

  test "delegates attributes in the main model" do
    @product_form.title = "iPhone 5S"
    assert_equal @product_form.title, @product.title

    @product_form.price = 399.90
    assert_equal @product_form.price, @product.price
  end

  test "product form responds to persisted?" do
    assert_not @product_form.persisted?

    product_form = ProductForm.new(products(:one))
    assert product_form.persisted?
  end

  test "product form responds to to_key" do
    assert_nil @product_form.to_key

    product_form = ProductForm.new(products(:one))
    assert_equal products(:one).id, product_form.to_key
  end

  test "product form responds to to_param" do
    assert_nil @product_form.to_param

    product_form = ProductForm.new(products(:one))
    assert_equal products(:one).id.to_s, product_form.to_param
  end

  test "product form responds to to_partial_path" do
    assert_equal "", @product_form.to_partial_path
  end

  test "product form responds to to_model" do
    assert_equal @product, @product_form.to_model
  end
end