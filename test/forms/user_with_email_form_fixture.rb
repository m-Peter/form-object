class UserWithEmailFormFixture < AbstractForm
  attributes :name, :age, :gender

  association :email do
    attribute :address

    validates :address, presence: true
  end

  validates :name, :age, :gender, presence: true
  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }
end