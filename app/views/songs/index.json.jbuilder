json.array!(@songs) do |song|
  json.extract! song, :id, :string, :string
  json.url song_url(song, format: :json)
end
