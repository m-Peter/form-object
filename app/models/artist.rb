class Artist < ActiveRecord::Base
  has_one :producer
  belongs_to :song

  validates :name, uniqueness: true
end
