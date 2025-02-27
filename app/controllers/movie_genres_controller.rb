class MovieGenresController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_token_and_cookie

  
    # POST /movie_genres
    def create
      movie_genre = MovieGenre.new(movie_genre_params)
      if movie_genre.save
        render json: movie_genre, status: :created
      else
        render json: { errors: movie_genre.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /movie_genres/:id
    def destroy
      movie_genre = MovieGenre.find(params[:id])
      movie_genre.destroy
      head :no_content
    end
  
    private
  
    def movie_genre_params
      params.require(:movie_genre).permit(:movie_id, :genre_id)
    end
  end
  