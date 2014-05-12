require 'test_helper'

class ComplianceTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = ProductForm.new(Product.new)
  end
end