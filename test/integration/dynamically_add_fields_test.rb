require 'test_helper'

class DynamicallyAddFieldsTest < ActionDispatch::IntegrationTest
  def setup
    Capybara.default_driver = :selenium
  end

  test "dynamically add a task field" do
    visit new_project_path

    assert_equal new_project_path, current_path
    assert find_link('Add a Task').visible?
    
    page.assert_selector(".field", :count => 4)
    
    click_link('Add a Task')
    page.assert_selector(".field", :count => 5)

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

    assert_select "p", "Project Name:\n  Life"
    assert_select "ol" do |elements|
      elements.each do |element|
        assert_select element, "li", "Eat"
        assert_select element, "li", "Pray"
        assert_select element, "li", "Love"
        assert_select element, "li", "Repeat"
      end
    end
  end

  #test "dynamically add a task field to existing Project" do
  test "one" do
    project = projects(:yard)

    visit edit_project_path(project)

    assert_equal edit_project_path(project), current_path
    assert find_link('Add a Task').visible?
    
    page.assert_selector(".field", :count => 4)

    click_link('Add a Task')
    page.assert_selector(".field", :count => 5)

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

    assert_select "p", "Project Name:\n  Yard Work"
    assert_select "ol" do |elements|
      elements.each do |element|
        assert_select element, "li", "rake the leaves"
        assert_select element, "li", "paint the fence"
        assert_select element, "li", "clean the gutters"
        assert_select element, "li", "plant red roses"
      end
    end
  end
end
