class MovieActorsController < ApplicationController
    before_action :authenticate_user!
  
    # POST /movie_actors
    def create
      movie_actor = MovieActor.new(movie_actor_params)
      if movie_actor.save
        render json: movie_actor, status: :created
      else
        render json: { errors: movie_actor.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /movie_actors/:id
    def destroy
      movie_actor = MovieActor.find(params[:id])
      movie_actor.destroy
      head :no_content
    end
  
    private
  
    def movie_actor_params
      params.require(:movie_actor).permit(:movie_id, :actor_id)
    end
  end
  