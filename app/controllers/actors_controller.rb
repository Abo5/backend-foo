class ActorsController < ApplicationController
    before_action :authenticate_user!
  
    # GET /actors
    def index
      actors = Actor.all
      render json: actors, status: :ok
    end
  
    # GET /actors/:id
    def show
      actor = Actor.find(params[:id])
      render json: actor, status: :ok
    end
  
    # POST /actors
    def create
      actor = Actor.new(actor_params)
      if actor.save
        render json: actor, status: :created
      else
        render json: { errors: actor.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /actors/:id
    def update
      actor = Actor.find(params[:id])
      if actor.update(actor_params)
        render json: actor, status: :ok
      else
        render json: { errors: actor.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /actors/:id
    def destroy
      actor = Actor.find(params[:id])
      actor.destroy
      head :no_content
    end
  
    private
  
    def actor_params
      params.require(:actor).permit(:name, :bio)
    end
  end
  