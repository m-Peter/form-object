require 'test_helper'

class ConferenceForm < AbstractForm
  attributes :name, :city

  association :speaker do
    attribute :name, :occupation

    association :presentations do
      attribute :topic, :duration
    end
  end
end

class ConferenceFormTest < ActiveSupport::TestCase
  
end