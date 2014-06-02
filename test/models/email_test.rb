require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  test "requires unique address" do
    peters = emails(:peters)
    new_email = Email.create(address: peters.address)

    assert_not new_email.valid?
  end
end
