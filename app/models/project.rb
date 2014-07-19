class Project < ActiveRecord::Base
  has_many :tasks, dependent: :destroy
  has_many :contributors, class_name: 'Person'
  belongs_to :owner, class_name: 'Person'

  validates :name, uniqueness: true
end
