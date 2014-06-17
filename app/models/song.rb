class Song < ActiveRecord::Base
  has_one :artist
end
