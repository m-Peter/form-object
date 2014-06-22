class ProjectWithTasksContainingDeliverableFormFixture < AbstractForm
  attribute :name

  association :tasks, records: 2 do
    attribute :name

    association :deliverable do
      attribute :description
    end

    validates :name, presence: true
  end

  validates :name, presence: true
end