class UserForm
  include ActiveModel::Validations
  attr_reader :user, :email
  
  delegate :address, :address=, to: :email
  delegate :name, :name=, :gender, :gender=, :age, :age=, to: :user

  validates :name, :age, :gender, presence: true
  validates :name, length: { in: 6..20 }
  validates :age, numericality: { only_integer: true }

  validates :address, presence: true
  validates_format_of :address, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def initialize(user, email)
    @user = user
    @email = email
  end
end