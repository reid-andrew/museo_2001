require 'minitest/autorun'
require 'minitest/pride'
require './lib/curator.rb'
require './lib/photograph.rb'
require './lib/artist.rb'

class CuratorTest < Minitest::Test

  def setup
    @curator = Curator.new
    @photo_1 = Photograph.new({
       id: "1",
       name: "Rue Mouffetard, Paris (Boy with Bottles)",
       artist_id: "1",
       year: "1954"
    })
    @photo_2 = Photograph.new({
       id: "2",
       name: "Moonrise, Hernandez",
       artist_id: "2",
       year: "1941"
     })
     @photo_3 = Photograph.new({
       id: "3",
       name: "Identical Twins, Roselle, New Jersey",
       artist_id: "3",
       year: "1967"
     })
     @photo_4 = Photograph.new({
       id: "4",
       name: "Monolith, The Face of Half Dome",
       artist_id: "3",
       year: "1927"
     })
     @artist_1 = Artist.new({
      id: "1",
      name: "Henri Cartier-Bresson",
      born: "1908",
      died: "2004",
      country: "France"
    })
    @artist_2 = Artist.new({
      id: "2",
      name: "Ansel Adams",
      born: "1902",
      died: "1984",
      country: "United States"
    })
    @artist_3 = Artist.new({
       id: "3",
       name: "Diane Arbus",
       born: "1923",
       died: "1971",
       country: "United States"
     })
  end

  def test_it_exists
    assert_instance_of Curator, @curator
  end

  def test_it_has_attributes
    assert_equal [], @curator.photographs
    assert_equal [], @curator.artists
  end

  def test_it_adds_photographs
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)

    assert_equal [@photo_1, @photo_2], @curator.photographs
  end

  def test_it_adds_artists
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)

    assert_equal [@artist_1, @artist_2], @curator.artists
  end

  def test_it_finds_artist_by_id
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)

    assert_equal @artist_1, @curator.find_artist_by_id("1")
    assert_nil @curator.find_artist_by_id("1999")
  end

  def test_it_finds_photo_by_artist_id
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)
    artist = Artist.new({
      id: "10",
      name: "Andy Warhol",
      born: "1928",
      died: "1987",
      country: "United States"
    })

    assert_equal [@photo_1], @curator.find_photo_by_artist_id(@artist_1)
    assert_equal [@photo_3, @photo_4], @curator.find_photo_by_artist_id(@artist_3)
    assert_equal [], @curator.find_photo_by_artist_id(artist)
  end

  def test_it_counts_photos_by_artist
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)
    artist = Artist.new({
      id: "10",
      name: "Andy Warhol",
      born: "1928",
      died: "1987",
      country: "United States"
    })

    assert_equal 1, @curator.count_of_photos_by_artist(@artist_1)
    assert_equal 2, @curator.count_of_photos_by_artist(@artist_3)
    assert_equal 0, @curator.count_of_photos_by_artist(artist)

  end

  def test_it_returns_photographs_by_artist
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)
    expected = {
      @artist_1 => [@photo_1],
      @artist_2 => [@photo_2],
      @artist_3 => [@photo_3, @photo_4]
    }

    assert_equal expected, @curator.photographs_by_artist
  end

  def test_it_finds_artists_with_multiple_photographs
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)

    assert_equal ["Diane Arbus"], @curator.artists_with_multiple_photographs
  end

  def test_it_finds_photographs_taken_by_artist_from_country
    @curator.add_artist(@artist_1)
    @curator.add_artist(@artist_2)
    @curator.add_artist(@artist_3)
    @curator.add_photograph(@photo_1)
    @curator.add_photograph(@photo_2)
    @curator.add_photograph(@photo_3)
    @curator.add_photograph(@photo_4)

    assert_equal [@photo_2, @photo_3, @photo_4], @curator.photographs_taken_by_artist_from("United States")
    assert_equal [], @curator.photographs_taken_by_artist_from("Argentina")
  end

  def test_it_loads_photographs
    assert_equal [], @curator.photographs

    @curator.load_photographs('./data/photographs.csv')

    assert_instance_of Photograph, @curator.photographs.sample
    assert_equal 4, @curator.photographs.size
    assert_equal @photo_1.name, @curator.photographs[0].name
    assert_equal @photo_1.id, @curator.photographs[0].id
    assert_equal "Child with Toy Hand Grenade in Central Park", @curator.photographs[3].name
    assert_equal "1962", @curator.photographs[3].year
  end

  def test_it_loads_artists
    assert_equal [], @curator.artists

    @curator.load_artists('./data/artists.csv')

    assert_instance_of Artist, @curator.artists.sample
    assert_equal 6, @curator.artists.size
    assert_equal @artist_1.name, @curator.artists[0].name
    assert_equal @artist_1.id, @curator.artists[0].id
    assert_equal "Walker Evans", @curator.artists[3].name
    assert_equal "United States", @curator.artists[5].country
  end

  def test_it_finds_photographs_between_dates
    @curator.load_photographs('./data/photographs.csv')
    expected = [@curator.photographs[0], @curator.photographs[3]]

    assert_equal expected, @curator.photographs_taken_between(1950..1965)

    expected = [@curator.photographs[0], @curator.photographs[1]]

    assert_equal expected, @curator.photographs_taken_between(1940..1955)
  end

  def test_it_gets_age_of_artist_when_photo_taken
    @curator.load_artists('./data/artists.csv')
    @curator.load_photographs('./data/photographs.csv')
    diane_arbus = @curator.find_artist_by_id("3")
    ident_twins = @curator.photographs[2]
    grenade_kid = @curator.photographs[3]

    assert_equal 44, @curator.artist_age(diane_arbus, ident_twins)
    assert_equal 39, @curator.artist_age(diane_arbus, grenade_kid)
  end

  def test_it_returns_photographs_by_artist_age
    @curator.load_artists('./data/artists.csv')
    @curator.load_photographs('./data/photographs.csv')
    expected = {44=>"Identical Twins, Roselle, New Jersey", 39=>"Child with Toy Hand Grenade in Central Park"}
    diane_arbus = @curator.find_artist_by_id("3")

    assert_equal expected, @curator.artists_photographs_by_age(diane_arbus)

    expected = {46 => "Rue Mouffetard, Paris (Boy with Bottles)"}
    henri = @curator.find_artist_by_id("1")

    assert_equal expected, @curator.artists_photographs_by_age(henri)
  end

end
