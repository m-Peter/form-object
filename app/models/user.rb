class User < ActiveRecord::Base
  act_as_gendered
  has_one :email
end
