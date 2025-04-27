class MoviesController < ApplicationController
  # before_action :check_token_cookie, only: [:index, :show, :create]
  before_action :set_movie, only: [:show, :update, :destroy]


  include AuthenticationTokenCookie

  # السماح بالوصول المجهول لـ home فقط
  before_action :authenticate_request, except: [:home]
  def home
  end
  # ---------------------------------------
  def index
    @movies = Movie.where(added_by_user_uuid: current_user.uuid)
    render json: @movies.map { |movie| movie_response(movie) }
  end

  # GET /movies/:uuid
  def show
    render json: movie_response(@movie)
  end

  # POST /movies
  def create
    movie_attrs = movie_params.except(:poster_file)
    movie_attrs[:runtime] = normalize_runtime(movie_attrs[:runtime])

    @movie = Movie.new(movie_attrs)
    @movie.added_by_user_uuid = current_user.uuid

    if params[:movie][:poster_file].present?
      @movie.poster.attach(params[:movie][:poster_file])
    end

    if @movie.save
      if @movie.poster.attached?
        @movie.update(poster_url: @movie.poster.blob.key)
      end
      render json: {
        message: 'Movie saved successfully',
        movie: movie_response(@movie)
      }, status: :created
    else
      render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /movies/:uuid/update
  def update
    movie_attrs = movie_params.except(:poster_file)
    movie_attrs[:runtime] = normalize_runtime(movie_attrs[:runtime])

    if params[:movie][:poster_file].present?
      @movie.poster.purge if @movie.poster.attached?
      @movie.poster.attach(params[:movie][:poster_file])
      movie_attrs[:poster_url] = rails_blob_path(@movie.poster, only_path: true)
    end

    if @movie.update(movie_attrs)
      render json: {
        message: 'Movie updated successfully',
        movie: movie_response(@movie)
      }, status: :ok
    else
      render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /movies/:uuid/delete
  def destroy
    @movie.poster.purge if @movie.poster.attached?
    if @movie.destroy
      render json: { message: 'Movie deleted successfully' }, status: :ok
    else
      render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_movie
    @movie = Movie.find_by!(uuid: params[:uuid])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Movie not found' }, status: :not_found
  end

  def movie_params
    params.require(:movie).permit(
      :title,
      :runtime,
      :overview,
      :production_company,
      :release_date,
      :director,
      :cast,
      :poster_url,
      :trailer_url,
      :imdb_age_rating,
      :poster_file
    )
  end

  def movie_response(movie)
    response = movie.as_json(except: [:added_by_user_uuid])
    response['added_by_user'] = current_user.username
    if movie.poster.attached?
      response['poster_url'] = movie.poster.blob.key
      response['poster_file'] = movie.poster.blob.key
    end
    response['film_notes_count'] = movie.film_notes.count
    response
  end

  def normalize_runtime(runtime_value)
    str = runtime_value.to_s.strip

    return str if str.match?(/\A\d{2}:\d{2}:\d{2}\z/)

    if str.match?(/\A\d{1,2}:\d{2}\z/)
      h, m = str.split(":").map(&:to_i)
      return "%02d:%02d:00" % [h, m]
    end

    if str.match?(/\A\d+\z/)
      total_minutes = str.to_i
      hours = total_minutes / 60
      minutes = total_minutes % 60
      return "%02d:%02d:00" % [hours, minutes]
    end

    str
  end

  def check_token_cookie
    unless verify_token_cookie_match
      render json: { error: 'Invalid token or user cookie.' }, status: :unauthorized
    end
  end
end
