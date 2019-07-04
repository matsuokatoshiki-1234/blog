class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  validates :title, presence: true, length: { maximum: 100 }
  validates :body, presence: true, length: { maximum: 500 }
  validates :image, presence: true, file_size: { less_than_or_equal_to: 5.megabytes }, file_content_type: { allow: ['image/jpeg', 'image/png', 'image/jpg', 'image/gif'] }
  mount_uploader :image, ImageUploader
end
