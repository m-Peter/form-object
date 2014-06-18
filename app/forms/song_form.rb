class SongForm < AbstractForm
  attributes :title, :length

  association :artist do
    attribute :name

    association :producer do
      attributes :name, :studio
    end
  end
end