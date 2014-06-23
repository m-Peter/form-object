require 'test_helper'
require_relative 'user_with_email_and_profile_form_fixture'
require_relative 'project_with_tasks_form_fixture'
require_relative 'songs_form_fixture'
require_relative 'user_form_fixture'
require_relative 'user_with_email_form_fixture'

class NestedModelRenderingTest < ActionView::TestCase
  def form_for(*)
    @output_buffer = super
  end

  test "form_for renders correctly a new instance of UserFormFixture" do
    user = User.new
    user_form = UserFormFixture.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

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

    assert_match /<input name="commit" type="submit" value="Create User" \/>/, output_buffer
  end

  test "form_for renders correctly a existing instance of UserFormFixture" do
    user = users(:peter)
    user_form = UserFormFixture.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

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

    assert_match /<input name="commit" type="submit" value="Update User" \/>/, output_buffer
  end

  test "form_for renders correctly a new instance of UserWithEmailFormFixture" do
    user = User.new
    user_form = UserWithEmailFormFixture.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.fields_for(:email, user_form.email) { |email_fields|
        concat email_fields.label(:address)
        concat email_fields.text_field(:address)
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

  test "form_for renders correctly a existing instance of UserWithEmailFormFixture" do
    user = users(:peter)
    user_form = UserWithEmailFormFixture.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.fields_for(:email, user_form.email) { |email_fields|
        concat email_fields.label(:address)
        concat email_fields.text_field(:address)
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
    assert_match /<input id="user_email_attributes_id" name="user\[email_attributes\]\[id\]" type="hidden" value="#{user_form.email.id}" \/>/, output_buffer

    assert_match /<input name="commit" type="submit" value="Update User" \/>/, output_buffer
  end

  test "form_for renders correctly a new instance of UserWithEmailAndProfileFormFixture" do
    user = User.new
    user_form = UserWithEmailAndProfileFormFixture.new(user)

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

  test "form_for renders correctly an existing instance of UserWithEmailAndProfileFormFixture" do
    user = users(:peter)
    user_form = UserWithEmailAndProfileFormFixture.new(user)

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
    assert_match /<input id="user_email_attributes_id" name="user\[email_attributes\]\[id\]" type="hidden" value="#{user_form.email.id}" \/>/, output_buffer

    assert_match /<label for="user_profile_attributes_twitter_name">Twitter name<\/label>/, output_buffer
    assert_match /<input id="user_profile_attributes_twitter_name" name="user\[profile_attributes\]\[twitter_name\]" type="text" value="#{user_form.profile.twitter_name}" \/>/, output_buffer
    assert_match /<label for="user_profile_attributes_github_name">Github name<\/label>/, output_buffer
    assert_match /<input id="user_profile_attributes_github_name" name="user\[profile_attributes\]\[github_name\]" type="text" value="#{user_form.profile.github_name}" \/>/, output_buffer
    assert_match /<input id="user_profile_attributes_id" name="user\[profile_attributes\]\[id\]" type="hidden" value="#{user_form.profile.id}" \/>/, output_buffer

    assert_match /<input name="commit" type="submit" value="Update User" \/>/, output_buffer
  end

  test "form_for renders correctly a new instance of Form Model containing a nested collection" do
    project = Project.new
    project_form = ProjectWithTasksFormFixture.new(project)

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
    project_form = ProjectWithTasksFormFixture.new(project)

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
      assert_match /<input id="project_tasks_attributes_#{i}_id" name="project\[tasks_attributes\]\[#{i}\]\[id\]" type="hidden" value="#{project_form.tasks[i].id}" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Update Project" \/>/, output_buffer
  end

  test "form_for renders correctly a new instance of Form Model with two nesting level" do
    song = Song.new
    song_form = SongsFormFixture.new(song)
    artist = song_form.artist
    producer = artist.producer

    form_for song_form do |f|
      concat f.label(:title)
      concat f.text_field(:title)
      concat f.label(:length)
      concat f.text_field(:length)

      concat f.fields_for(:artist, artist) { |a|
        concat a.label(:name)
        concat a.text_field(:name)

        concat a.fields_for(:producer, producer) { |p| 
          concat p.label(:name)
          concat p.text_field(:name)
          concat p.label(:studio)
          concat p.text_field(:studio)
        }
      }
    end

    assert_match /action="\/songs"/, output_buffer
    assert_match /class="new_song"/, output_buffer
    assert_match /id="new_song"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="song_title">Title<\/label>/, output_buffer
    assert_match /<input id="song_title" name="song\[title\]" type="text" \/>/, output_buffer
    assert_match /<label for="song_length">Length<\/label>/, output_buffer
    assert_match /input id="song_length" name="song\[length\]" type="text" \/>/, output_buffer
    
    assert_match /<label for="song_artist_attributes_name">Name<\/label>/, output_buffer
    assert_match /<input id="song_artist_attributes_name" name="song\[artist_attributes\]\[name\]" type="text" \/>/, output_buffer

    assert_match /<label for="song_artist_attributes_producer_attributes_name">Name<\/label>/, output_buffer
    assert_match /<input id="song_artist_attributes_producer_attributes_name" name="song\[artist_attributes\]\[producer_attributes\]\[name\]" type="text" \/>/, output_buffer
    assert_match /<label for="song_artist_attributes_producer_attributes_studio">Studio<\/label>/, output_buffer
    assert_match /<input id="song_artist_attributes_producer_attributes_studio" name="song\[artist_attributes\]\[producer_attributes\]\[studio\]" type="text" \/>/, output_buffer
  end

  test "form_for renders correctly a existing instance of Form Model with two nesting level" do
    song = songs(:lockdown)
    song_form = SongsFormFixture.new(song)
    artist = song_form.artist
    producer = artist.producer

    form_for song_form do |f|
      concat f.label(:title)
      concat f.text_field(:title)
      concat f.label(:length)
      concat f.text_field(:length)

      concat f.fields_for(:artist, artist) { |a|
        concat a.label(:name)
        concat a.text_field(:name)

        concat a.fields_for(:producer, producer) { |p| 
          concat p.label(:name)
          concat p.text_field(:name)
          concat p.label(:studio)
          concat p.text_field(:studio)
        }
      }
    end

    id = song.id

    assert_match /action="\/songs\/#{id}"/, output_buffer
    assert_match /class="edit_song"/, output_buffer
    assert_match /id="edit_song_#{id}"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="song_title">Title<\/label>/, output_buffer
    assert_match /<input id="song_title" name="song\[title\]" type="text" value="#{song_form.title}" \/>/, output_buffer
    assert_match /<label for="song_length">Length<\/label>/, output_buffer
    assert_match /input id="song_length" name="song\[length\]" type="text" value="#{song_form.length}" \/>/, output_buffer

    assert_match /<label for="song_artist_attributes_name">Name<\/label>/, output_buffer
    assert_match /<input id="song_artist_attributes_name" name="song\[artist_attributes\]\[name\]" type="text" value="#{artist.name}" \/>/, output_buffer

    assert_match /<label for="song_artist_attributes_producer_attributes_name">Name<\/label>/, output_buffer
    assert_match /<input id="song_artist_attributes_producer_attributes_name" name="song\[artist_attributes\]\[producer_attributes\]\[name\]" type="text" value="#{producer.name}" \/>/, output_buffer
    assert_match /<label for="song_artist_attributes_producer_attributes_studio">Studio<\/label>/, output_buffer
    assert_match /<input id="song_artist_attributes_producer_attributes_studio" name="song\[artist_attributes\]\[producer_attributes\]\[studio\]" type="text" value="#{producer.studio}" \/>/, output_buffer
  end
end