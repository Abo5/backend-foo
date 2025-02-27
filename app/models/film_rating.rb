class FilmRating < ApplicationRecord
  belongs_to :movie
  belongs_to :user

  VALID_CLASSIFICATIONS = %w[G PG PG12 PG15 R15 R18].freeze

  validates :classification, presence: true, inclusion: { in: VALID_CLASSIFICATIONS, message: "must be one of: #{VALID_CLASSIFICATIONS.join(', ')}" }
  validates :movie_id, uniqueness: { scope: :user_id, message: "You have already rated this movie" }
end
