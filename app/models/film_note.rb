class FilmNote < ApplicationRecord
  before_create :generate_uuid

  belongs_to :movie
  belongs_to :user

  validates :note, presence: true
  validates :time_in, presence: true, format: { 
    with: /\A\d{2}:\d{2}:\d{2}:\d{2}\z/, 
    message: "must be in the format HH:MM:SS:FF" 
  }
  validates :time_out, presence: true, format: { 
    with: /\A\d{2}:\d{2}:\d{2}:\d{2}\z/, 
    message: "must be in the format HH:MM:SS:FF" 
  }
  validates :action, presence: true

  private

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end  
end
