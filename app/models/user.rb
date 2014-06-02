class User < ActiveRecord::Base
  act_as_gendered
  has_one :email
  accepts_nested_attributes_for :email
end
