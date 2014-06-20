class ConferenceForm < AbstractForm
  attributes :name, :city

  association :speaker do
    attribute :name, :occupation

    association :presentations, records: 2 do
      attribute :topic, :duration
    end
  end
end