class Producer < ActiveRecord::Base
  belongs_to :artist, dependent: :destroy

  validates :name, :studio, uniqueness: true
end
