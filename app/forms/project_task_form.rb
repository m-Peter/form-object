class ProjectTaskForm
  include ActiveModel::Model

  attr_reader :project

  delegate :name, :name=, to: :project

  def initialize(project)
    @project = project
    args = {assoc_name: :tasks, records: 3, parent: @project}
    @collection = CollectionTask.new(args)
  end

  def tasks_attributes=(attributes) ; end

  def tasks
    @collection.models
  end

  def to_model
    project
  end
end

class CollectionTask
  attr_reader :association_name, :records, :parent

  def initialize(args)
    @association_name = args[:assoc_name]
    @records = args[:records]
    @parent = args[:parent]
  end

  def models
    if parent.persisted?
      parent.send(association_name)
    else
      build_records
    end
  end

  private

  def build_records
    result = []
    
    records.times do
      result << SubTask.new(parent)
    end

    result
  end
end

class SubTask
  include ActiveModel::Model

  attr_reader :task

  delegate :name, :name=, to: :task

  def initialize(parent)
    @parent = parent
    @task = @parent.tasks.build
  end

  def to_model
    task
  end
end