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

  test "remove a dynamic added Task field from Project" do
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

  test "dynamically add a Question field to new Survey" do
    visit new_survey_path

    assert_equal new_survey_path, current_path
    assert find_link('Add a Question').visible?

    assert_equal 3, all(:xpath, "//a[@class='remove_fields dynamic']").size

    click_link('Add a Question')
    assert_equal 6, all(:xpath, "//a[@class='remove_fields dynamic']").size

    assert_difference('Survey.count') do
      post_via_redirect "/surveys", survey: {
        name: "Programming languages",

        questions_attributes: {
          "0" => {
            content: "Which language allows closures?",

            answers_attributes: {
              "0" => { content: "Ruby Programming Language" },
              "1" => { content: "CSharp Programming Language" }
            }
          },
          "1404292088779" => {
            content: "Which language allows blocks?",

            answers_attributes: {
              "0" => { content: "Ruby Programming Language" },
              "1" => { content: "C Programming Language" }
            }
          }
        }
      }
    end

    survey = Survey.last

    survey.questions.each do |question|
      assert question.persisted?
      assert_equal 2, question.answers.size

      question.answers.each do |answer|
        assert answer.persisted?
      end
    end

    assert_equal "Programming languages", survey.name
    assert_equal "Which language allows closures?", survey.questions[0].content
    assert_equal "Ruby Programming Language", survey.questions[0].answers[0].content
    assert_equal "CSharp Programming Language", survey.questions[0].answers[1].content
    assert_equal "Which language allows blocks?", survey.questions[1].content
    assert_equal "Ruby Programming Language", survey.questions[1].answers[0].content
    assert_equal "C Programming Language", survey.questions[1].answers[1].content

    assert_equal "/surveys/#{survey.id}", path
    assert_template :show
  end

  test "remove a dynamic added Question field from Survey" do
    survey = surveys(:programming)

    visit edit_survey_path(survey)

    assert_equal edit_survey_path(survey), current_path
    assert find_link('Add a Question').visible?

    assert_equal 3, all(:xpath, "//a[@class='remove_fields existing']").size

    click_link('Add a Question')
    assert_equal 3, all(:xpath, "//a[@class='remove_fields dynamic']").size

    all(:xpath, "//a[text()='remove']").last.click

    assert_equal 0, all(:xpath, "//a[@class='remove_fields dynamic']").size

    assert_difference('Survey.count', 0) do
      patch_via_redirect "/surveys/#{survey.id}", survey: {
        name: survey.name,

        questions_attributes: {
          "0" => {
            content: "Which language is spoken in England?",
            id: questions(:one).id,

            answers_attributes: {
              "0" => { content: "The English Language", id: answers(:ruby).id },
              "1" => { content: "The Latin Language", id: answers(:cs).id },
            }
          }
        }
      }
    end

    assert_equal 1, survey.questions.size
    assert_equal 2, survey.questions[0].answers.size

    assert_equal "Your favorite programming language", survey.name
    assert_equal "Which language is spoken in England?", survey.questions[0].content
    assert_equal "The Latin Language", survey.questions[0].answers[0].content
    assert_equal "The English Language", survey.questions[0].answers[1].content

    assert_equal "/surveys/#{survey.id}", path
    assert_template :show
  end

  test "dynamically add a Question field to existing Survey" do
    survey = surveys(:programming)

    visit edit_survey_path(survey)

    assert_equal edit_survey_path(survey), current_path
    assert find_link('Add a Question').visible?

    assert_equal 3, all(:xpath, "//a[@class='remove_fields existing']").size

    click_link('Add a Question')
    assert_equal 3, all(:xpath, "//a[@class='remove_fields dynamic']").size

    assert_difference('Survey.count', 0) do
      patch_via_redirect "/surveys/#{survey.id}", survey: {
        name: survey.name,

        questions_attributes: {
          "0" => {
            content: "Which language is spoken in England?",
            id: questions(:one).id,

            answers_attributes: {
              "0" => { content: "The English Language", id: answers(:ruby).id },
              "1" => { content: "The Latin Language", id: answers(:cs).id },
            }
          },
          "21342141565" => {
            content: "Which language is spoken in Canada?",

            answers_attributes: {
              "0" => { content: "The English Language" },
              "1" => { content: "The Canadian Language" },
            }
          }
        }
      }
    end

    assert_equal 2, survey.questions.size
    assert_equal 2, survey.questions[0].answers.size

    assert_equal "Your favorite programming language", survey.name
    assert_equal "Which language is spoken in England?", survey.questions[0].content
    assert_equal "The Latin Language", survey.questions[0].answers[0].content
    assert_equal "The English Language", survey.questions[0].answers[1].content
    assert_equal "Which language is spoken in Canada?", survey.questions[1].content
    assert_equal "The English Language", survey.questions[1].answers[0].content
    assert_equal "The Canadian Language", survey.questions[1].answers[1].content

    assert_equal "/surveys/#{survey.id}", path
    assert_template :show
  end

  test "dynamically remove a Question field from existing Survey" do
    survey = surveys(:programming)

    visit edit_survey_path(survey)

    assert_equal edit_survey_path(survey), current_path
    assert find_link('Add a Question').visible?

    assert_equal 3, all(:xpath, "//a[@class='remove_fields existing']").size

    all(:xpath, "//a[text()='remove']").last.click

    assert_equal 0, all(:xpath, "//a[@class='remove_fields dynamic']").size

    assert_difference('Survey.count', 0) do
      patch_via_redirect "/surveys/#{survey.id}", survey: {
        name: survey.name,

        questions_attributes: {
          "0" => {
            content: "Which language is spoken in England?",
            id: questions(:one).id,
            "_destroy" => "1",

            answers_attributes: {
              "0" => { content: "The English Language", id: answers(:ruby).id },
              "1" => { content: "The Latin Language", id: answers(:cs).id },
            }
          }
        }
      }
    end

    assert_equal 0, survey.questions.size
  end

end
