class Product < ActiveRecord::Base
  validates :title, uniqueness: true
end
