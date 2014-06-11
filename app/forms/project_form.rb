class ProjectForm < AbstractForm
  attribute :name

  collection :tasks, records: 3 do
    attribute :name

    validates :name, presence: true
  end

  validates :name, presence: true
end