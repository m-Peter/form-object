require 'test_helper'
require_relative 'nested_model_form'

class NestedModelRenderingTest < ActionView::TestCase
  def form_for(*)
    @output_buffer = super
  end

  test "form_for is rendered correctly in the new template" do
    user = User.new
    user_form = NestedModelForm.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)
      concat f.label(:age)
      concat f.number_field(:age)
      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.fields_for(:email, user_form.email) { |e|
        concat e.label(:address)
        concat e.text_field(:address)
      }

      concat f.submit
    end

    assert_match /action="\/users"/, output_buffer
    assert_match /class="new_user"/, output_buffer
    assert_match /id="new_user"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="user_name">Name<\/label>/, output_buffer
    assert_match /<input id="user_name" name="user\[name\]" type="text" \/>/, output_buffer
    assert_match /<label for="user_age">Age<\/label>/, output_buffer
    assert_match /input id="user_age" name="user\[age\]" type="number" \/>/, output_buffer
    assert_match /<label for="user_gender">Gender<\/label>/, output_buffer
    assert_match /<select id="user_gender" name="user\[gender\]">/, output_buffer
    assert_match /<option value="0">Male<\/option>/, output_buffer
    assert_match /<option value="1">Female<\/option>/, output_buffer
    assert_match /<\/select>/, output_buffer

    assert_match /<label for="user_email_attributes_address">Address<\/label>/, output_buffer
    assert_match /<input id="user_email_attributes_address" name="user\[email_attributes\]\[address\]" type="text" \/>/, output_buffer

    assert_match /<input name="commit" type="submit" value="Create User" \/>/, output_buffer
  end
end