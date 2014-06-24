require 'test_helper'
require_relative 'user_with_email_and_profile_form_fixture'
require_relative 'project_with_tasks_form_fixture'
require_relative 'project_with_tasks_containing_deliverable_form_fixture'
require_relative 'songs_form_fixture'
require_relative 'user_form_fixture'
require_relative 'user_with_email_form_fixture'
require_relative 'conference_form_fixture'
require_relative 'survey_form_fixture'

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

      concat f.fields_for(:email, user_form.email) { |email_fields|
        concat email_fields.label(:address)
        concat email_fields.text_field(:address)
      }

      concat f.fields_for(:profile, user_form.profile) { |profile_fields|
        concat profile_fields.label(:twitter_name)
        concat profile_fields.text_field(:twitter_name)

        concat profile_fields.label(:github_name)
        concat profile_fields.text_field(:github_name)
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

      concat f.fields_for(:email, user_form.email) { |email_fields|
        concat email_fields.label(:address)
        concat email_fields.text_field(:address)
      }

      concat f.fields_for(:profile, user_form.profile) { |profile_fields|
        concat profile_fields.label(:twitter_name)
        concat profile_fields.text_field(:twitter_name)

        concat profile_fields.label(:github_name)
        concat profile_fields.text_field(:github_name)
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

  test "form_for renders correctly a new instance of ProjectWithTasksFormFixture" do
    project = Project.new
    project_form = ProjectWithTasksFormFixture.new(project)

    form_for project_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:tasks, project_form.tasks) { |task_fields|
        concat task_fields.label(:task)
        concat task_fields.text_field(:name)
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

  test "form_for renders correctly a existing instance of ProjectWithTasksFormFixture" do
    project = projects(:yard)
    project_form = ProjectWithTasksFormFixture.new(project)

    form_for project_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:tasks, project_form.tasks) { |task_fields|
        concat task_fields.label(:task)
        concat task_fields.text_field(:name)
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

  test "form_for renders correctly a new instance of ProjectWithTasksContainingDeliverableFormFixture" do
    project = Project.new
    project_form = ProjectWithTasksContainingDeliverableFormFixture.new(project)
    tasks = project_form.tasks

    form_for project_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:tasks, tasks) { |task_fields|
        concat task_fields.label(:task)
        concat task_fields.text_field(:name)

        concat task_fields.fields_for(:deliverable, task_fields.object.deliverable) { |deliverable_fields|
          concat deliverable_fields.label(:description)
          concat deliverable_fields.text_field(:description)
        }
      }

      concat f.submit
    end

    assert_match /action="\/projects"/, output_buffer
    assert_match /class="new_project"/, output_buffer
    assert_match /id="new_project"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="project_name">Name<\/label>/, output_buffer
    assert_match /<input id="project_name" name="project\[name\]" type="text" \/>/, output_buffer

    [0, 1].each do |i|
      assert_match /<label for="project_tasks_attributes_#{i}_task">Task<\/label>/, output_buffer
      assert_match /<input id="project_tasks_attributes_#{i}_name" name="project\[tasks_attributes\]\[#{i}\]\[name\]" type="text" \/>/, output_buffer

      assert_match /<label for="project_tasks_attributes_#{i}_deliverable_attributes_description">Description<\/label>/, output_buffer
      assert_match /<input id="project_tasks_attributes_#{i}_deliverable_attributes_description" name="project\[tasks_attributes\]\[#{i}\]\[deliverable_attributes\]\[description\]" type="text" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Create Project" \/>/, output_buffer
  end

  test "form_for renders correctly a existing instance of ProjectWithTasksContainingDeliverableFormFixture" do
    project = projects(:yard)
    project_form = ProjectWithTasksFormFixture.new(project)
    tasks = project_form.tasks

    form_for project_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:tasks, tasks) { |task_fields|
        concat task_fields.label(:task)
        concat task_fields.text_field(:name)

        concat task_fields.fields_for(:deliverable) { |deliverable_fields|
          concat deliverable_fields.label(:description)
          concat deliverable_fields.text_field(:description)
        }
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

    [0, 1].each do |i|
      assert_match /<label for="project_tasks_attributes_#{i}_task">Task<\/label>/, output_buffer
      assert_match /<input id="project_tasks_attributes_#{i}_name" name="project\[tasks_attributes\]\[#{i}\]\[name\]" type="text" value="#{project_form.tasks[i].name}" \/>/, output_buffer
      assert_match /<input id="project_tasks_attributes_#{i}_id" name="project\[tasks_attributes\]\[#{i}\]\[id\]" type="hidden" value="#{project_form.tasks[i].id}" \/>/, output_buffer

      #assert_match /<label for="project_tasks_attributes_#{i}_deliverable_description">Description<\/label>/, output_buffer
      #assert_match /<input id="project_tasks_attributes_#{i}_deliverable_attributes_description" name="project\[tasks_attributes\]\[#{i}\]\[deliverable_attributes\]\[description\]" type="text" value="this" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Update Project" \/>/, output_buffer
  end

  test "form_for renders correctly a new instance of SongsFormFixture" do
    song = Song.new
    song_form = SongsFormFixture.new(song)
    artist = song_form.artist
    producer = artist.producer

    form_for song_form do |f|
      concat f.label(:title)
      concat f.text_field(:title)

      concat f.label(:length)
      concat f.text_field(:length)

      concat f.fields_for(:artist, artist) { |artist_fields|
        concat artist_fields.label(:name)
        concat artist_fields.text_field(:name)

        concat artist_fields.fields_for(:producer, producer) { |producer_fields| 
          concat producer_fields.label(:name)
          concat producer_fields.text_field(:name)

          concat producer_fields.label(:studio)
          concat producer_fields.text_field(:studio)
        }
      }

      concat f.submit
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

    assert_match /<input name="commit" type="submit" value="Create Song" \/>/, output_buffer
  end

  test "form_for renders correctly a existing instance of SongsFormFixture" do
    song = songs(:lockdown)
    song_form = SongsFormFixture.new(song)
    artist = song_form.artist
    producer = artist.producer

    form_for song_form do |f|
      concat f.label(:title)
      concat f.text_field(:title)

      concat f.label(:length)
      concat f.text_field(:length)

      concat f.fields_for(:artist, artist) { |artist_fields|
        concat artist_fields.label(:name)
        concat artist_fields.text_field(:name)

        concat artist_fields.fields_for(:producer, producer) { |producer_fields| 
          concat producer_fields.label(:name)
          concat producer_fields.text_field(:name)

          concat producer_fields.label(:studio)
          concat producer_fields.text_field(:studio)
        }
      }

      concat f.submit
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
    assert_match /<input id="song_artist_attributes_id" name="song\[artist_attributes\]\[id\]" type="hidden" value="#{artist.id}" \/>/, output_buffer

    assert_match /<label for="song_artist_attributes_producer_attributes_name">Name<\/label>/, output_buffer
    assert_match /<input id="song_artist_attributes_producer_attributes_name" name="song\[artist_attributes\]\[producer_attributes\]\[name\]" type="text" value="#{producer.name}" \/>/, output_buffer
    assert_match /<label for="song_artist_attributes_producer_attributes_studio">Studio<\/label>/, output_buffer
    assert_match /<input id="song_artist_attributes_producer_attributes_studio" name="song\[artist_attributes\]\[producer_attributes\]\[studio\]" type="text" value="#{producer.studio}" \/>/, output_buffer
    assert_match /<input id="song_artist_attributes_producer_attributes_id" name="song\[artist_attributes\]\[producer_attributes\]\[id\]" type="hidden" value="#{producer.id}" \/>/, output_buffer

    assert_match /<input name="commit" type="submit" value="Update Song" \/>/, output_buffer
  end

  test "form_for renders correctly a new instance of ConferenceFormFixture" do
    conference = Conference.new
    conference_form = ConferenceFormFixture.new(conference)
    speaker = conference_form.speaker
    presentations = speaker.presentations

    form_for conference_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:city)
      concat f.text_field(:city)

      concat f.fields_for(:speaker, speaker) { |speaker_fields|
        concat speaker_fields.label(:name)
        concat speaker_fields.text_field(:name)

        concat speaker_fields.label(:occupation)
        concat speaker_fields.text_field(:occupation)

        concat speaker_fields.fields_for(:presentations, presentations) { |presentation_fields|
          concat presentation_fields.label(:topic)
          concat presentation_fields.text_field(:topic)

          concat presentation_fields.label(:duration)
          concat presentation_fields.text_field(:duration)
        }
      }

      concat f.submit
    end

    assert_match /action="\/conferences"/, output_buffer
    assert_match /class="new_conference"/, output_buffer
    assert_match /id="new_conference"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="conference_name">Name<\/label>/, output_buffer
    assert_match /<input id="conference_name" name="conference\[name\]" type="text" \/>/, output_buffer
    assert_match /<label for="conference_city">City<\/label>/, output_buffer
    assert_match /<input id="conference_city" name="conference\[city\]" type="text" \/>/, output_buffer

    assert_match /<label for="conference_speaker_attributes_name">Name<\/label>/, output_buffer
    assert_match /<input id="conference_speaker_attributes_name" name="conference\[speaker_attributes\]\[name\]" type="text" \/>/, output_buffer
    assert_match /<label for="conference_speaker_attributes_occupation">Occupation<\/label>/, output_buffer
    assert_match /<input id="conference_speaker_attributes_occupation" name="conference\[speaker_attributes\]\[occupation\]" type="text" \/>/, output_buffer

    [0, 1].each do |i|
      assert_match /<label for="conference_speaker_attributes_presentations_attributes_#{i}_topic">Topic<\/label>/, output_buffer
      assert_match /<input id="conference_speaker_attributes_presentations_attributes_#{i}_topic" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[topic\]" type="text" \/>/, output_buffer
      assert_match /<label for="conference_speaker_attributes_presentations_attributes_#{i}_duration">Duration<\/label>/, output_buffer
      assert_match /<input id="conference_speaker_attributes_presentations_attributes_#{i}_duration" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[duration\]" type="text" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Create Conference" \/>/, output_buffer
  end

  test "form_for renders correct a existing instance of ConferenceFormFixture" do
    conference = conferences(:ruby)
    conference_form = ConferenceFormFixture.new(conference)
    speaker = conference_form.speaker
    presentations = speaker.presentations

    form_for conference_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:city)
      concat f.text_field(:city)

      concat f.fields_for(:speaker, speaker) { |speaker_fields|
        concat speaker_fields.label(:name)
        concat speaker_fields.text_field(:name)

        concat speaker_fields.label(:occupation)
        concat speaker_fields.text_field(:occupation)

        concat speaker_fields.fields_for(:presentations, presentations) { |presentation_fields|
          concat presentation_fields.label(:topic)
          concat presentation_fields.text_field(:topic)

          concat presentation_fields.label(:duration)
          concat presentation_fields.text_field(:duration)
        }
      }

      concat f.submit
    end

    id = conference.id

    assert_match /action="\/conferences\/#{id}"/, output_buffer
    assert_match /class="edit_conference"/, output_buffer
    assert_match /id="edit_conference_#{id}"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="conference_name">Name<\/label>/, output_buffer
    assert_match /<input id="conference_name" name="conference\[name\]" type="text" value="#{conference_form.name}" \/>/, output_buffer
    assert_match /<label for="conference_city">City<\/label>/, output_buffer
    assert_match /<input id="conference_city" name="conference\[city\]" type="text" value="#{conference_form.city}" \/>/, output_buffer
    
    assert_match /<label for="conference_speaker_attributes_name">Name<\/label>/, output_buffer
    assert_match /<input id="conference_speaker_attributes_name" name="conference\[speaker_attributes\]\[name\]" type="text" value="#{speaker.name}" \/>/, output_buffer
    assert_match /<label for="conference_speaker_attributes_occupation">Occupation<\/label>/, output_buffer
    assert_match /<input id="conference_speaker_attributes_occupation" name="conference\[speaker_attributes\]\[occupation\]" type="text" value="#{speaker.occupation}" \/>/, output_buffer
    assert_match /<input id="conference_speaker_attributes_id" name="conference\[speaker_attributes\]\[id\]" type="hidden" value="#{speaker.id}" \/>/, output_buffer

    [0, 1].each do |i|
      assert_match /<label for="conference_speaker_attributes_presentations_attributes_#{i}_topic">Topic<\/label>/, output_buffer
      assert_match /<input id="conference_speaker_attributes_presentations_attributes_#{i}_topic" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[topic\]" type="text" value="#{presentations[i].topic}" \/>/, output_buffer
      assert_match /<label for="conference_speaker_attributes_presentations_attributes_#{i}_duration">Duration<\/label>/, output_buffer
      assert_match /<input id="conference_speaker_attributes_presentations_attributes_#{i}_duration" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[duration\]" type="text" value="#{presentations[i].duration}" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Update Conference" \/>/, output_buffer
  end

  test "form_for renders correctly a new instance of SurveyFormFixture" do
    survey = Survey.new
    survey_form = SurveyFormFixture.new(survey)
    questions = survey_form.questions

    form_for survey_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:questions, questions) { |question_fields|
        concat question_fields.label(:content)
        concat question_fields.text_field(:content)

        concat question_fields.fields_for(:answers, question_fields.object.answers) { |answer_fields|
          concat answer_fields.label(:content)
          concat answer_fields.text_field(:content)
        }
      }

      concat f.submit
    end

    assert_match /action="\/surveys"/, output_buffer
    assert_match /class="new_survey"/, output_buffer
    assert_match /id="new_survey"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="survey_name">Name<\/label>/, output_buffer
    assert_match /<input id="survey_name" name="survey\[name\]" type="text" \/>/, output_buffer

    assert_match /<label for="survey_questions_attributes_0_content">Content<\/label>/, output_buffer
    assert_match /<input id="survey_questions_attributes_0_content" name="survey\[questions_attributes\]\[0\]\[content\]" type="text" \/>/, output_buffer

    [0, 1].each do |i|
      assert_match /<label for="survey_questions_attributes_0_answers_attributes_#{i}_content">Content<\/label>/, output_buffer
      assert_match /<input id="survey_questions_attributes_0_answers_attributes_#{i}_content" name="survey\[questions_attributes\]\[0\]\[answers_attributes\]\[#{i}\]\[content\]" type="text" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Create Survey" \/>/, output_buffer
  end

  test "form_for renders correctly a existing instance of SurveyFormFixture" do
    survey = surveys(:programming)
    survey_form = SurveyFormFixture.new(survey)
    questions = survey_form.questions

    form_for survey_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:questions, questions) { |question_fields|
        concat question_fields.label(:content)
        concat question_fields.text_field(:content)

        concat question_fields.fields_for(:answers, question_fields.object.answers) { |answer_fields|
          concat answer_fields.label(:content)
          concat answer_fields.text_field(:content)
        }
      }

      concat f.submit
    end

    id = survey.id

    assert_match /action="\/surveys\/#{id}"/, output_buffer
    assert_match /class="edit_survey"/, output_buffer
    assert_match /id="edit_survey_#{id}"/, output_buffer
    assert_match /method="post"/, output_buffer

    assert_match /<label for="survey_name">Name<\/label>/, output_buffer
    assert_match /<input id="survey_name" name="survey\[name\]" type="text" value="#{survey_form.name}" \/>/, output_buffer
  
    assert_match /<label for="survey_questions_attributes_0_content">Content<\/label>/, output_buffer
    assert_match /<input id="survey_questions_attributes_0_content" name="survey\[questions_attributes\]\[0\]\[content\]" type="text" value="Which language allows closures\?" \/>/, output_buffer
  
    [0, 1].each do |i|
      assert_match /<label for="survey_questions_attributes_0_answers_attributes_#{i}_content">Content<\/label>/, output_buffer
      assert_match /<input id="survey_questions_attributes_0_answers_attributes_#{i}_content" name="survey\[questions_attributes\]\[0\]\[answers_attributes\]\[#{i}\]\[content\]" type="text" value="#{questions[0].answers[i].content}" \/>/, output_buffer
    end

    assert_match /<input name="commit" type="submit" value="Update Survey" \/>/, output_buffer
  end
end