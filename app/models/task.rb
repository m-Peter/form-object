class Task < ActiveRecord::Base
  belongs_to :project
  validates :name, uniqueness: true
end
