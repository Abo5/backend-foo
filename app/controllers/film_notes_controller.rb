class FilmNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movie, only: [:index, :create, :add_by_post]  # أضف :add_by_post هنا
  before_action :set_film_note, only: [:update, :destroy]
  
  def index
    @notes = @movie.film_notes
    render json: @notes
  end

  def create
    @film_note = @movie.film_notes.new(film_note_params)
    @film_note.user = current_user
    @film_note.user_name = current_user.username  # حفظ اسم المستخدم
  
    if @film_note.save
      render json: { message: "Note created successfully", film_note: @film_note }, status: :created
    else
      render json: { errors: @film_note.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def add_by_post
    # هنا يُفترض أن movie_uuid موجود في params ويتم تعيين @movie في set_movie
    film_note_data = params.require(:film_note).permit(:note, :time_in, :time_out, :action)
    @film_note = @movie.film_notes.new(film_note_data)
    @film_note.user = current_user
    @film_note.user_name = current_user.username if @film_note.respond_to?(:user_name)

    if @film_note.save
      render json: { message: "Note created successfully", film_note: @film_note }, status: :created
    else
      render json: { errors: @film_note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @film_note.user == current_user && @film_note.update(film_note_params)
      render json: { message: "Note updated successfully", film_note: @film_note }
    else
      render json: { errors: @film_note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @film_note.user == current_user && @film_note.destroy
      render json: { message: "Note deleted successfully" }
    else
      render json: { errors: "Unable to delete note" }, status: :unprocessable_entity
    end
  end

  private

  def set_movie
    if params[:movie_uuid].blank?
      render json: { error: "Movie uuid not provided" }, status: :unprocessable_entity and return
    end
  
    @movie = Movie.find_by(uuid: params[:movie_uuid])
    unless @movie
      render json: { error: "Movie not found" }, status: :not_found and return
    end
  end
  
  def set_film_note
    film_note_id = params.dig(:film_note, :id)
    if film_note_id.blank?
      render json: { error: "Film note id not provided" }, status: :unprocessable_entity and return
    end
    @film_note = FilmNote.find(film_note_id)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Film note not found" }, status: :not_found
  end

  def film_note_params
    params.require(:film_note).permit(:note, :time_in, :time_out, :action)
  end
end
