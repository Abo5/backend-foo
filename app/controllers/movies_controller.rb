class MoviesController < ApplicationController
  include AuthenticationTokenCookie
  before_action :check_token_cookie, only: [:index, :show, :create]
  before_action :set_movie, only: [:show, :update, :destroy]

  # GET /movies
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
    @movie = Movie.new(movie_params.except(:poster_file))
    # تعيين معرف المستخدم الذي قام بإنشاء الفيلم
    @movie.added_by_user_uuid = current_user.uuid
  
    if params[:movie][:poster_file].present?
      # إرفاق الملف قبل حفظ السجل حتى يتم استيفاء شرط التحقق
      @movie.poster.attach(params[:movie][:poster_file])
    end
  
    if @movie.save
      # تحديث poster_url إذا تم رفع الملف
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
      # بدلاً من إعادة مسار التحويل، نعيد مفتاح الصورة مباشرة
      response['poster_url'] = movie.poster.blob.key
      # إذا أردت أيضًا حقل poster_file يمكن إضافته بنفس القيمة:
      response['poster_file'] = movie.poster.blob.key
    end
    response
  end
  
  
  

  private

  def check_token_cookie
    unless verify_token_cookie_match
      render json: { error: 'Invalid token or user cookie.' }, status: :unauthorized
    end
  end
end