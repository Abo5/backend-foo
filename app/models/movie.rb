class Movie < ApplicationRecord
  before_create :generate_uuid

  has_many :film_notes, dependent: :destroy
  has_many :film_ratings, dependent: :destroy   # ← أضف هذه السطر
  has_one_attached :poster

  validates :title, presence: true
  validates :runtime, presence: true, format: { 
    with: /\A\d{2}:\d{2}:\d{2}\z/, 
    message: "must be in the format HH:MM:SS" 
  }
  validates :poster_url, format: { 
    with: /\Ahttps?:\/\/.*\.(jpg|jpeg|png)\z/i, 
    message: "must be a valid image URL (jpg, jpeg, png)" 
  }, allow_blank: true

  # تحقق مخصص لضمان وجود صورة مرفقة أو رابط URL صالح
  validate :poster_presence

  def added_by_user_name
    user = User.find_by(uuid: added_by_user_uuid)
    user ? user.username : nil
  end

  private

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def acceptable_poster
    return unless poster.attached?
    unless poster.blob.byte_size <= 10.megabyte
      errors.add(:poster, "must be less than 10MB")
    end
    acceptable_types = ["image/jpeg", "image/jpg", "image/png"]
    unless acceptable_types.include?(poster.content_type)
      errors.add(:poster, "must be a JPEG or PNG or JPG")
    end
  end

  def poster_presence
    unless poster.attached? || (poster_url.present? && poster_url =~ /\Ahttps?:\/\/.*\.(jpg|jpeg|png)\z/i)
      errors.add(:base, "You must provide either an attached poster image or a valid poster URL (e.g., http://example.com/image.jpg)")
    end
  end
end
