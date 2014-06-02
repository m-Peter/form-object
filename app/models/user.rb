class User < ActiveRecord::Base
  has_one :email
end
