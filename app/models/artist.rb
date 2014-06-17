class Artist < ActiveRecord::Base
  has_one :producer
  belongs_to :song
end
