class FilmRatingsController < ApplicationController
  # before_action :authenticate_user!

  # الإجراء التقليدي (POST /film_ratings) موجود كما هو
  def create
    film_rating = FilmRating.new(film_rating_params)
    film_rating.user = current_user
    if film_rating.save
      render json: film_rating, status: :created
    else
      render json: { errors: film_rating.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # تعديل تقييم باستخدام PUT (الطريقة التقليدية)
  def update
    film_rating = FilmRating.find(params[:id])
    if film_rating.user == current_user && film_rating.update(film_rating_params)
      render json: film_rating, status: :ok
    else
      render json: { errors: film_rating.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # حذف تقييم (الطريقة التقليدية)
  def destroy
    film_rating = FilmRating.find(params[:id])
    if film_rating.user == current_user && film_rating.destroy
      head :no_content
    else
      render json: { errors: "Unable to delete rating" }, status: :unprocessable_entity
    end
  end

  # إضافة تقييم جديد باستخدام POST مع movie_uuid
  def add_by_post
    if params[:movie_uuid].blank?
      render json: { error: "Movie uuid not provided" }, status: :unprocessable_entity and return
    end

    movie = Movie.find_by(uuid: params[:movie_uuid])
    unless movie
      render json: { error: "Movie not found" }, status: :not_found and return
    end

    film_rating = movie.film_ratings.new(film_rating_params)
    film_rating.user = current_user

    if film_rating.save
      render json: {
        message: "Film rating created successfully",
        film_rating: film_rating.as_json(only: [:id, :classification, :created_at, :updated_at])
                        .merge({
                          movie_uuid: movie.uuid,
                          writer: current_user.username,
                          writer_uuid: current_user.uuid
                        })
      }, status: :created
    else
      render json: { errors: film_rating.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # تحديث تقييم باستخدام movie_uuid
  def update_by_post
    if params[:movie_uuid].blank?
      render json: { error: "Movie uuid not provided" }, status: :unprocessable_entity and return
    end

    movie = Movie.find_by(uuid: params[:movie_uuid])
    unless movie
      render json: { error: "Movie not found" }, status: :not_found and return
    end

    # البحث عن تقييم للفيلم خاص بالمستخدم الحالي
    film_rating = movie.film_ratings.find_by(user: current_user)
    unless film_rating
      render json: { error: "Film rating not found for current user" }, status: :not_found and return
    end

    if film_rating.update(film_rating_params)
      render json: {
        message: "Film rating updated successfully",
        film_rating: film_rating.as_json(only: [:id, :classification, :created_at, :updated_at])
                        .merge({
                          movie_uuid: movie.uuid,
                          writer: current_user.username,
                          writer_uuid: current_user.uuid
                        })
      }, status: :ok
    else
      render json: { errors: film_rating.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def film_rating_params
    # movie_id غير مطلوب لأنه نستخدم movie_uuid من الرابط
    params.require(:film_rating).permit(:classification)
  end
end
