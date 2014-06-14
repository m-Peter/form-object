require 'test_helper'
require_relative 'nested_models_form'
require_relative 'nested_collection_association_form'

class NestedModelRenderingTest < ActionView::TestCase
  def form_for(*)
    @output_buffer = super
  end

  test "form_for renders correctly a new instance of Form Model" do
    user = User.new
    user_form = NestedModelsForm.new(user)

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

      concat f.fields_for(:profile, user_form.profile) { |p|
        concat p.label(:twitter_name)
        concat p.text_field(:twitter_name)
        concat p.label(:github_name)
        concat p.text_field(:github_name)
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

    assert_match /<label for="user_profile_attributes_twitter_name">Twitter name<\/label>/, output_buffer
    assert_match /<input id="user_profile_attributes_twitter_name" name="user\[profile_attributes\]\[twitter_name\]" type="text" \/>/, output_buffer
    assert_match /<label for="user_profile_attributes_github_name">Github name<\/label>/, output_buffer
    assert_match /<input id="user_profile_attributes_github_name" name="user\[profile_attributes\]\[github_name\]" type="text" \/>/, output_buffer

    assert_match /<input name="commit" type="submit" value="Create User" \/>/, output_buffer
  end

  test "form_for renders correctly an existing instance of Form Model" do
    user = users(:peter)
    user_form = NestedModelsForm.new(user)

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

      concat f.fields_for(:profile, user_form.profile) { |p|
        concat p.label(:twitter_name)
        concat p.text_field(:twitter_name)
        concat p.label(:github_name)
        concat p.text_field(:github_name)
      }

      concat f.submit
    end

    id = user.id

    assert_match /action="\/users\/#{id}"/, output_buffer
    assert_match /class="edit_user"/, output_buffer
    assert_match /id="edit_user_#{id}"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="user_name">Name<\/label>/, output_buffer
    assert_match /<input id="user_name" name="user\[name\]" type="text" value="#{user_form.name}" \/>/, output_buffer
    assert_match /<label for="user_age">Age<\/label>/, output_buffer
    assert_match /<input id="user_age" name="user\[age\]" type="number" value="#{user_form.age}" \/>/, output_buffer
    assert_match /<label for="user_gender">Gender<\/label>/, output_buffer
    assert_match /<select id="user_gender" name="user\[gender\]">/, output_buffer
    assert_match /<option selected="selected" value="0">Male<\/option>/, output_buffer
    assert_match /<option value="1">Female<\/option>/, output_buffer
    assert_match /<\/select>/, output_buffer

    assert_match /<label for="user_email_attributes_address">Address<\/label>/, output_buffer
    assert_match /<input id="user_email_attributes_address" name="user\[email_attributes\]\[address\]" type="text" value="#{user_form.email.address}" \/>/, output_buffer

    assert_match /<label for="user_profile_attributes_twitter_name">Twitter name<\/label>/, output_buffer
    assert_match /<input id="user_profile_attributes_twitter_name" name="user\[profile_attributes\]\[twitter_name\]" type="text" value="#{user_form.profile.twitter_name}" \/>/, output_buffer
    assert_match /<label for="user_profile_attributes_github_name">Github name<\/label>/, output_buffer
    assert_match /<input id="user_profile_attributes_github_name" name="user\[profile_attributes\]\[github_name\]" type="text" value="#{user_form.profile.github_name}" \/>/, output_buffer

    assert_match /<input name="commit" type="submit" value="Update User" \/>/, output_buffer
  end

  test "form_for renders correctly a new instance of Form Model containing a nested collection" do
    project = Project.new
    project_form = NestedCollectionAssociationForm.new(project)

    form_for project_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:tasks, project_form.tasks) { |t|
        concat t.label(:task)
        concat t.text_field(:name)
      }

      concat f.submit
    end

    assert_match /action="\/projects"/, output_buffer
    assert_match /class="new_project"/, output_buffer
    assert_match /id="new_project"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="project_name">Name<\/label>/, output_buffer
    assert_match /<input id="project_name" name="project\[name\]" type="text" \/>/, output_buffer

    [0, 1, 2].each do |i|
      assert_match /<label for="project_tasks_attributes_#{i}_task">Task<\/label>/, output_buffer
      assert_match /<input id="project_tasks_attributes_#{i}_name" name="project\[tasks_attributes\]\[#{i}\]\[name\]" type="text" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Create Project" \/>/, output_buffer
  end

  test "form_for renders correctly a existing instance of Form Model containing a nested collection" do
    project = projects(:yard)
    project_form = NestedCollectionAssociationForm.new(project)

    form_for project_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:tasks, project_form.tasks) { |t|
        concat t.label(:task)
        concat t.text_field(:name)
      }

      concat f.submit
    end

    id = project.id

    assert_match /action="\/projects\/#{id}"/, output_buffer
    assert_match /class="edit_project"/, output_buffer
    assert_match /id="edit_project_#{id}"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="project_name">Name<\/label>/, output_buffer
    assert_match /<input id="project_name" name="project\[name\]" type="text" value="#{project_form.name}" \/>/, output_buffer

    [0, 1, 2].each do |i|
      assert_match /<label for="project_tasks_attributes_#{i}_task">Task<\/label>/, output_buffer
      assert_match /<input id="project_tasks_attributes_#{i}_name" name="project\[tasks_attributes\]\[#{i}\]\[name\]" type="text" value="#{project_form.tasks[i].name}" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Update Project" \/>/, output_buffer
  end
end