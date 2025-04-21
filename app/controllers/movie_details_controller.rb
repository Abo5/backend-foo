# app/controllers/movie_details_controller.rb
class MovieDetailsController < ApplicationController
    include AuthenticationTokenCookie
    # before_action :authenticate_user!
    before_action :set_movie
  
    # GET /movie_details/:uuid
    def show
      # صلاحيات الوصول:
      # - إذا كان المستخدم admin أو super_admin، فله صلاحية رؤية جميع الأفلام.
      # - إذا كان المستخدم monitor، يرى فقط الفيلم الذي أضافه بنفسه.
      if current_user.role.in?(%w[admin super_admin]) || (@movie.added_by_user_uuid == current_user.uuid)
        render json: movie_details_response(@movie), status: :ok
      else
        render json: { error: "Access denied" }, status: :forbidden
      end
    end
  
    private
  
    def set_movie
      @movie = Movie.find_by!(uuid: params[:uuid])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Movie not found" }, status: :not_found
    end
  
    def movie_details_response(movie)
      # بيانات المُنشئ
      creator = User.find_by(uuid: movie.added_by_user_uuid)
      
      # تجهيز بيانات الفيلم الأساسية (باستثناء الحقل الذي يُخزن UUID للمنشئ)
      movie_data = movie.as_json(except: [:added_by_user_uuid])
      movie_data['added_by_user'] = creator ? creator.username : "Unknown"
      
      # إذا كانت الصورة مرفقة، نعيد مفتاح الصورة (poster_file) بدلاً من مسار URL
      if movie.poster.attached?
        movie_data['poster_file'] = movie.poster.blob.key
        movie_data['poster_url']  = movie.poster.blob.key
      end
  
      # إضافة تفاصيل الملاحظات الخاصة بالفيلم
      movie_data['film_notes'] = movie.film_notes.includes(:user).map do |note|
        {
          id: note.id,
          note: note.note,
          time_in: note.time_in,
          time_out: note.time_out,
          action: note.action,
          created_at: note.created_at,
          updated_at: note.updated_at,
          written_by: note.user ? note.user.username : "Unknown",
          writer_uuid: note.user ? note.user.uuid : nil
        }
      end
  
      # إضافة تفاصيل تقييمات الفيلم
      movie_data['film_ratings'] = movie.film_ratings.includes(:user).map do |rating|
        {
          id: rating.id,
          classification: rating.classification,
          created_at: rating.created_at,
          updated_at: rating.updated_at,
          rated_by: rating.user ? rating.user.username : "Unknown",
          rater_uuid: rating.user ? rating.user.uuid : nil
        }
      end
  
      movie_data
    end
  end
  
