class AddImdbAgeRatingToMovies < ActiveRecord::Migration[8.0]
  def change
    add_column :movies, :imdb_age_rating, :string
  end
end
