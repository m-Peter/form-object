require 'test_helper'

class DynamicallyAddFieldsTest < ActionDispatch::IntegrationTest
  def setup
    Capybara.default_driver = :selenium
  end

  test "dynamically add a task field" do
    visit new_project_path

    assert_equal current_path, new_project_path
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
end
