require 'test_helper'

class SongsControllerTest < ActionController::TestCase
  setup do
    @song = songs(:lockdown)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:songs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create song" do
    assert_difference(['Song.count', 'Artist.count', 'Producer.count']) do
      post :create, song: {
        title: "Diamonds",
        length: "360",

        artist_attributes: {
          name: "Karras",

          producer_attributes: {
            name: "Phoebos",
            studio: "MADog"
          }
        }
      }
    end

    song_form = assigns(:song_form)

    assert_redirected_to song_path(song_form)
    assert_equal "Diamonds", song_form.title
    assert_equal "360", song_form.length
    assert_equal "Karras", song_form.artist.name
    assert_equal "Phoebos", song_form.artist.producer.name
    assert_equal "MADog", song_form.artist.producer.studio
    assert_equal "Song: Diamonds was successfully created.", flash[:notice]
  end

  test "should show song" do
    get :show, id: @song
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @song
    assert_response :success
  end

  test "should update song" do
    patch :update, id: @song, song: {
      title: "Run this town",
      length: "355",

      artist_attributes: {
        name: "Rihanna",

        producer_attributes: {
          name: "Eminem",
          studio: "Marshall"
        }
      }
    }
    
    song_form = assigns(:song_form)

    assert_redirected_to song_path(song_form)
    assert_equal "Run this town", song_form.title
    assert_equal "355", song_form.length
    assert_equal "Rihanna", song_form.artist.name
    assert_equal "Eminem", song_form.artist.producer.name
    assert_equal "Marshall", song_form.artist.producer.studio
    assert_equal "Song: Run this town was successfully updated.", flash[:notice]
  end

  test "should destroy song" do
    assert_difference('Song.count', -1) do
      delete :destroy, id: @song
    end

    assert_redirected_to songs_path
  end
end
