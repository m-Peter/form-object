class Profile < ActiveRecord::Base
  belongs_to :user

  validates :twitter_name, :github_name, uniquenes: true
end
