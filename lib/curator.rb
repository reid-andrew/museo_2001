require './lib/fileIO.rb'

class Curator
  include FileIO

  attr_reader :photographs, :artists

  def initialize
    @photographs = []
    @artists = []
  end

  def add_photograph(photo)
    @photographs << photo
  end

  def add_artist(artist)
    @artists << artist
  end

  def find_artist_by_id(id)
    @artists.find { |artist| artist.id == id}
  end

  def find_photo_by_artist_id(artist)
    @photographs.select { |photo| photo.artist_id == artist.id}
  end

  def count_of_photos_by_artist(artist)
    find_photo_by_artist_id(artist).size
  end

  def photographs_by_artist
    @artists.reduce ({}) do |photos_by_artist, artist|
      photos_by_artist[artist] = find_photo_by_artist_id(artist)
      photos_by_artist
    end
  end

  def artists_with_multiple_photographs
    multi_photo_artists = []
    @artists.each do |artist|
      multi_photo_artists << artist.name if count_of_photos_by_artist(artist) > 1
    end
    multi_photo_artists
  end

  def photographs_taken_by_artist_from(country)
    country_photos = []
    @artists.each do |artist|
      country_photos << find_photo_by_artist_id(artist) if artist.country == country
    end
    country_photos.flatten
  end

  def load_photographs(path)
    create(path, @photographs, Photograph)
  end

  def load_artists(path)
    create(path, @artists, Artist)
  end

  def photographs_taken_between(range)
    @photographs.select do |photograph|
      range.include?(photograph.year.to_i)
    end
  end

  def artist_age(artist, photograph)
    photograph.year.to_i - artist.born.to_i
  end

  def artists_photographs_by_age(artist)
    photographs_by_artist[artist].reduce ({}) do |photos_by_age, photo|
      photos_by_age[artist_age(artist, photo)] = photo.name
      photos_by_age
    end
  end

end
