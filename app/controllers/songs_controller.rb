class SongsController < ApplicationController
  before_action :set_song, only: [:show, :edit, :update, :destroy]

  # GET /songs
  # GET /songs.json
  def index
    @songs = Song.all
  end

  # GET /songs/1
  # GET /songs/1.json
  def show
  end

  # GET /songs/new
  def new
    song = Song.new
    @song_form = SongForm.new(song)
  end

  # GET /songs/1/edit
  def edit
    song = Song.find(params[:id])
    @song_form = SongForm.new(song)
  end

  # POST /songs
  # POST /songs.json
  def create
    song = Song.new
    @song_form = SongForm.new(song)
    @song_form.submit(song_params)

    respond_to do |format|
      if @song_form.save
        format.html { redirect_to @song_form, notice: "Song: #{@song_form.title} was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /songs/1
  # PATCH/PUT /songs/1.json
  def update
    @song_form = SongForm.new(@song)
    @song_form.submit(song_params)

    respond_to do |format|
      if @song_form.save
        format.html { redirect_to @song_form, notice: "Song: #{@song_form.title} was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.json
  def destroy
    title = @song.title
    @song.destroy

    respond_to do |format|
      format.html { redirect_to songs_url, notice: "Song: #{title} was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def song_params
      params.require(:song).permit(:title, :length, artist_attributes: [ :name, producer_attributes: [ :name, :studio ] ] )
    end
end
