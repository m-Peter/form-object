class UserForm
  include ActiveModel::Model
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

  def valid?
    super
    validate_models
    collect_errors_from_models

    errors.empty?
  end

  def submit(params)
    params.each do |key, value|
      send("#{key}=", value)
    end
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        @user.email = email
        @user.save
        true
      end
    else
      false
    end
  end

  def persisted?
    @user.persisted?
  end

  def to_key
    return nil unless persisted?
    @user.id
  end

  def to_param
    return nil unless persisted?
    @user.id.to_s
  end

  def to_model
    @user
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end

  private

  def validate_models
    [user, email].each do |model|
      model.valid?
    end
  end

  def collect_errors_from_models
    [user, email].each do |model|
      collect_model_errors(model)
    end
  end

  def collect_model_errors(model)
    model.errors.each do |attribute, error|
      errors.add(attribute, error)
    end
  end
end