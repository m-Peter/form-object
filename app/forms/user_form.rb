class UserForm
  attr_reader :user, :email
  
  delegate :address, :address=, to: :email
  delegate :name, :name=, :gender, :gender=, :age, :age=, to: :user

  def initialize(user, email)
    @user = user
    @email = email
  end
end