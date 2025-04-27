# app/controllers/admin_controller.rb
class AdminController < ApplicationController
  include AuthenticationTokenCookie

  before_action :authenticate_request        # still require a valid JWT
  before_action :authorize_admin!            # …but only real admins get in

  # ───────────────────────────────────────────────
  # GET /admin/users           (or /maven_and_cinema/admin/users - see routes)
  # Returns a hash { "username" => "email", … }
  # ───────────────────────────────────────────────
  def users
    render json: { users: User.pluck(:username, :email).to_h }
  end

  # ───────────────────────────────────────────────
  # POST /movies/admin
  # Creates **one movie per e-mail** and marks that user as the creator.
  # Request body:
  #   movie[title]        – required
  #   movie[runtime]      – 01:30:00, 90, 1:30 … anything normalize_runtime handles
  #   …all the regular movie fields…
  #   movie[poster_file]  – optional multipart file
  #   user_emails[]       – *array* of e-mails (at least 1)
  # ───────────────────────────────────────────────
  def add_movie
    emails = Array(params[:user_emails]).map(&:strip).reject(&:blank?)
    return render json: { error: 'user_emails[] is required' }, status: :unprocessable_entity if emails.empty?

    # common payload for every copy of the movie
    base_attrs           = movie_params.except(:poster_file)
    base_attrs[:runtime] = normalize_runtime(base_attrs[:runtime])

    poster_io = params.dig(:movie, :poster_file) # can be nil – attach once per movie

    created, errors = [], []

    emails.each do |email|
      user = User.find_by(email: email)
      unless user
        errors << { email:, message: 'user not found' }
        next
      end

      movie = Movie.new(base_attrs.merge(added_by_user_uuid: user.uuid))
      movie.poster.attach(poster_io) if poster_io.present?

      if movie.save
        movie.update(poster_url: movie.poster.blob.key) if movie.poster.attached?
        created << { email:, uuid: movie.uuid, title: movie.title }
      else
        errors << { email:, message: movie.errors.full_messages }
      end
    end

    status = errors.empty? ? :created : :multi_status
    render json: { created:, errors: }, status:
  end

  private

  # same strong params used by MoviesController
  def movie_params
    params.require(:movie).permit(
      :title, :runtime, :overview, :production_company, :release_date,
      :director, :cast, :poster_url, :trailer_url, :imdb_age_rating,
      :poster_file
    )
  end

  # copy of MoviesController#normalize_runtime so we do not duplicate logic
  def normalize_runtime(value)
    MoviesController.new.send(:normalize_runtime, value)
  end

  def authorize_admin!
    return if current_user&.role.in?(%w[admin super_admin])

    render json: { error: 'Access denied – admin only' }, status: :forbidden
  end
end
