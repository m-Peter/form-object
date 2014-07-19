class ProjectWithPeopleFixture < AbstractForm
  attribute :name, required: true
  attribute :owner_id

  association :contributors, records: 2 do
    attributes :name, :role, :description, required: true
  end
end