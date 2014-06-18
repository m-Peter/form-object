class TwoNestingLevelForm < AbstractForm
  attributes :title, :length

  association :artist do
    attribute :name

    association :producer do
      attributes :name, :studio
    end
  end

  validates :title, :length, presence: true
end