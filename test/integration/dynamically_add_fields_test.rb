require 'test_helper'

class DynamicallyAddFieldsTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = false

  def setup
    Capybara.default_driver = :selenium
  end

  test "dynamically add a Task field to new Project" do
    visit new_project_path

    assert_equal new_project_path, current_path
    assert find_link('Add a Task').visible?
    
    assert_equal 3, all(:xpath, "//a[@class='remove_fields dynamic']").size
    page.assert_selector(".field", :count => 4)
    
    click_link('Add a Task')
    page.assert_selector(".field", :count => 5)
    assert_equal 4, all(:xpath, "//a[@class='remove_fields dynamic']").size

    assert_difference('Project.count') do
      post_via_redirect "/projects", project: {
        name: "Life",

        tasks_attributes: {
          "0" => { name: "Eat" },
          "1" => { name: "Pray" },
          "2" => { name: "Love" },
          "1404292088779" => { name: "Repeat" }
        }
      }
    end

    project = Project.last

    assert_equal "Life", project.name
    assert_equal 4, project.tasks.size
    project.tasks.each do |task|
      task.persisted?
    end
    assert_equal "Eat", project.tasks[0].name
    assert_equal "Pray", project.tasks[1].name
    assert_equal "Love", project.tasks[2].name
    assert_equal "Repeat", project.tasks[3].name
    
    assert_equal "/projects/#{project.id}", path
    assert_template :show
  end

  test "remove a dynamic added Task Field from Project" do
    project = projects(:yard)

    visit edit_project_path(project)

    assert_equal edit_project_path(project), current_path
    assert find_link('Add a Task').visible?
    
    page.assert_selector(".field", :count => 4)
    assert_equal 3, all(:xpath, "//a[@class='remove_fields existing']").size

    click_link('Add a Task')
    assert_equal 1, all(:xpath, "//a[@class='remove_fields dynamic']").size
    page.assert_selector(".field", :count => 5)
    
    all(:xpath, "//a[@class='remove_fields dynamic']").last.click

    page.assert_selector(".field", :count => 4)

    assert_difference('Project.count', 0) do
      patch_via_redirect "/projects/#{project.id}", project: {
        name: project.name,

        tasks_attributes: {
          "0" => { name: tasks(:rake).name, id: tasks(:rake).id },
          "1" => { name: tasks(:paint).name, id: tasks(:paint).id },
          "2" => { name: tasks(:clean).name, id: tasks(:clean).id },
        }
      }
    end

    assert_equal "Yard Work", project.name
    assert_equal 3, project.tasks.size
    project.tasks.each do |task|
      task.persisted?
    end
    assert_equal "rake the leaves", project.tasks[0].name
    assert_equal "paint the fence", project.tasks[1].name
    assert_equal "clean the gutters", project.tasks[2].name
    
    assert_equal "/projects/#{project.id}", path
    assert_template :show
  end

  test "dynamically add a Task field to existing Project" do
    project = projects(:yard)

    visit edit_project_path(project)

    assert_equal edit_project_path(project), current_path
    assert find_link('Add a Task').visible?
    assert_equal 3, all(:xpath, "//a[@class='remove_fields existing']").size
    
    page.assert_selector(".field", :count => 4)

    click_link('Add a Task')
    page.assert_selector(".field", :count => 5)
    assert_equal 1, all(:xpath, "//a[@class='remove_fields dynamic']").size

    assert_difference('Project.count', 0) do
      patch_via_redirect "/projects/#{project.id}", project: {
        name: project.name,

        tasks_attributes: {
          "0" => { name: tasks(:rake).name, id: tasks(:rake).id },
          "1" => { name: tasks(:paint).name, id: tasks(:paint).id },
          "2" => { name: tasks(:clean).name, id: tasks(:clean).id },
          "1404292088779" => { name: "plant red roses" }
        }
      }
    end

    assert_equal "Yard Work", project.name
    assert_equal 4, project.tasks.size
    project.tasks.each do |task|
      task.persisted?
    end
    assert_equal "rake the leaves", project.tasks[0].name
    assert_equal "paint the fence", project.tasks[1].name
    assert_equal "clean the gutters", project.tasks[2].name
    assert_equal "plant red roses", project.tasks[3].name
    
    assert_equal "/projects/#{project.id}", path
    assert_template :show
  end

  test "dynamically remove a Task field from existing Project" do
    project = projects(:yard)

    visit edit_project_path(project)

    assert_equal edit_project_path(project), current_path
    assert_equal 3, all(:xpath, "//a[@class='remove_fields existing']").size
    
    page.assert_selector(".field", :count => 4)

    all(:xpath, "//a[@class='remove_fields existing']").last.click

    click_button "Update Project"

    project = Project.find(project.id)

    assert_equal 2, project.tasks.size
    project.tasks.each do |task|
      task.persisted?
    end

    assert_equal "Yard Work", project.name
    assert_equal "rake the leaves", project.tasks[0].name
    assert_equal "paint the fence", project.tasks[1].name
  end

  test "dynamically add a Presentation field to new Conference" do
    visit new_conference_path

    assert_equal new_conference_path, current_path
    assert find_link('Add a Presentation').visible?

    assert_equal 2, all(:xpath, "//a[@class='remove_fields dynamic']").size

    click_link("Add a Presentation")
    assert_equal 3, all(:xpath, "//a[@class='remove_fields dynamic']").size

    assert_difference(['Conference.count', 'Speaker.count']) do
      post_via_redirect "/conferences", conference: {
        name: "Euruco",
        city: "Athens",

        speaker_attributes: {
          name: "Petros Markou",
          occupation: "Developer",

          presentations_attributes: {
            "0" => { topic: "Ruby OOP", duration: "1h" },
            "1" => { topic: "Ruby Closures", duration: "1h" },
            "1404292088779" => { topic: "Ruby Blocks", duration: "1h" }
          }
        }
      }
    end

    conference = Conference.last

    assert_equal 3, conference.speaker.presentations.size
    conference.speaker.presentations.each do |presentation|
      assert presentation.persisted?
    end

    assert_equal "Euruco", conference.name
    assert_equal "Athens", conference.city
    assert_equal "Petros Markou", conference.speaker.name
    assert_equal "Developer", conference.speaker.occupation
    assert_equal "Ruby OOP", conference.speaker.presentations[0].topic
    assert_equal "1h", conference.speaker.presentations[0].duration
    assert_equal "Ruby Closures", conference.speaker.presentations[1].topic
    assert_equal "1h", conference.speaker.presentations[1].duration
    assert_equal "Ruby Blocks", conference.speaker.presentations[2].topic
    assert_equal "1h", conference.speaker.presentations[2].duration

    assert_equal "/conferences/#{conference.id}", path
    assert_template :show
  end

  test "remove a dynamic added Presentation field from Conference" do
    conference = conferences(:ruby)

    visit edit_conference_path(conference)

    assert_equal edit_conference_path(conference), current_path
    assert find_link('Add a Presentation').visible?

    assert_equal 2, all(:xpath, "//a[@class='remove_fields existing']").size

    click_link('Add a Presentation')
    assert_equal 1, all(:xpath, "//a[@class='remove_fields dynamic']").size

    all(:xpath, "//a[@class='remove_fields dynamic']").last.click

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      patch_via_redirect "/conferences/#{conference.id}", conference: {
        name: conferences(:ruby).name,
        city: conferences(:ruby).city,

        speaker_attributes: {
          name: speakers(:peter).name,
          occupation: speakers(:peter).occupation,
          id: speakers(:peter).id,

          presentations_attributes: {
            "0" => { topic: presentations(:ruby_oop).topic, duration: presentations(:ruby_oop).duration, id: presentations(:ruby_oop).id },
            "1" => { topic: presentations(:ruby_closures).topic, duration: presentations(:ruby_closures).duration, id: presentations(:ruby_closures).id }
          }
        }
      }
    end

    assert_equal 2, conference.speaker.presentations.size

    assert_equal "EuRuCo", conference.name
    assert_equal "Athens", conference.city
    assert_equal "Peter Markou", conference.speaker.name
    assert_equal "Developer", conference.speaker.occupation
    assert_equal "Ruby Closures", conference.speaker.presentations[0].topic
    assert_equal "1h", conference.speaker.presentations[0].duration
    assert_equal "Ruby OOP", conference.speaker.presentations[1].topic
    assert_equal "1h", conference.speaker.presentations[1].duration
    
    assert_equal "/conferences/#{conference.id}", path
    assert_template :show
  end

  test "dynamically add a Presentation field to existing Conference" do
    conference = conferences(:ruby)

    visit edit_conference_path(conference)

    assert_equal edit_conference_path(conference), current_path
    assert find_link('Add a Presentation').visible?

    assert_equal 2, all(:xpath, "//a[@class='remove_fields existing']").size

    click_link('Add a Presentation')
    assert_equal 1, all(:xpath, "//a[@class='remove_fields dynamic']").size

    all(:xpath, "//a[@class='remove_fields dynamic']").last.click

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      patch_via_redirect "/conferences/#{conference.id}", conference: {
        name: conferences(:ruby).name,
        city: conferences(:ruby).city,

        speaker_attributes: {
          name: speakers(:peter).name,
          occupation: speakers(:peter).occupation,
          id: speakers(:peter).id,

          presentations_attributes: {
            "0" => { topic: presentations(:ruby_oop).topic, duration: presentations(:ruby_oop).duration, id: presentations(:ruby_oop).id },
            "1" => { topic: presentations(:ruby_closures).topic, duration: presentations(:ruby_closures).duration, id: presentations(:ruby_closures).id },
            "1404292088779" => { topic: "Ruby Blocks", duration: "0.5h" }
          }
        }
      }
    end

    assert_equal 3, conference.speaker.presentations.size

    assert_equal "EuRuCo", conference.name
    assert_equal "Athens", conference.city
    assert_equal "Peter Markou", conference.speaker.name
    assert_equal "Developer", conference.speaker.occupation
    assert_equal "Ruby Closures", conference.speaker.presentations[0].topic
    assert_equal "1h", conference.speaker.presentations[0].duration
    assert_equal "Ruby OOP", conference.speaker.presentations[1].topic
    assert_equal "1h", conference.speaker.presentations[1].duration
    assert_equal "Ruby Blocks", conference.speaker.presentations[2].topic
    assert_equal "0.5h", conference.speaker.presentations[2].duration
    
    assert_equal "/conferences/#{conference.id}", path
    assert_template :show
  end

  test "dynamically remove a Presentation field from existing Conference" do
    conference = conferences(:ruby)

    visit edit_conference_path(conference)

    assert_equal edit_conference_path(conference), current_path
    assert find_link('Add a Presentation').visible?

    assert_equal 2, all(:xpath, "//a[@class='remove_fields existing']").size

    click_link('Add a Presentation')
    assert_equal 1, all(:xpath, "//a[@class='remove_fields dynamic']").size

    all(:xpath, "//a[@class='remove_fields dynamic']").last.click

    assert_difference(['Conference.count', 'Speaker.count'], 0) do
      patch_via_redirect "/conferences/#{conference.id}", conference: {
        name: conferences(:ruby).name,
        city: conferences(:ruby).city,

        speaker_attributes: {
          name: speakers(:peter).name,
          occupation: speakers(:peter).occupation,
          id: speakers(:peter).id,

          presentations_attributes: {
            "0" => { topic: presentations(:ruby_oop).topic, duration: presentations(:ruby_oop).duration, id: presentations(:ruby_oop).id, "_destroy" => "1" },
            "1" => { topic: presentations(:ruby_closures).topic, duration: presentations(:ruby_closures).duration, id: presentations(:ruby_closures).id },
          }
        }
      }
    end

    assert_equal 1, conference.speaker.presentations.size

    assert_equal "EuRuCo", conference.name
    assert_equal "Athens", conference.city
    assert_equal "Peter Markou", conference.speaker.name
    assert_equal "Developer", conference.speaker.occupation
    assert_equal "Ruby Closures", conference.speaker.presentations[0].topic
    assert_equal "1h", conference.speaker.presentations[0].duration
    
    assert_equal "/conferences/#{conference.id}", path
    assert_template :show
  end
end
