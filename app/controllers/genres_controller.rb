class GenresController < ApplicationController
    before_action :authenticate_user!
  
    # GET /genres
    def index
      genres = Genre.all
      render json: genres, status: :ok
    end
  
    # GET /genres/:id
    def show
      genre = Genre.find(params[:id])
      render json: genre, status: :ok
    end
  
    # POST /genres
    def create
      genre = Genre.new(genre_params)
      if genre.save
        render json: genre, status: :created
      else
        render json: { errors: genre.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /genres/:id
    def update
      genre = Genre.find(params[:id])
      if genre.update(genre_params)
        render json: genre, status: :ok
      else
        render json: { errors: genre.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /genres/:id
    def destroy
      genre = Genre.find(params[:id])
      genre.destroy
      head :no_content
    end
  
    private
  
    def genre_params
      params.require(:genre).permit(:name)
    end
  end
  