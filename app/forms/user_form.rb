class UserForm
  attr_reader :user
  
  delegate :name, :name=, :gender, :gender=, :age, :age=, to: :user

  def initialize(user)
    @user = user
  end
end