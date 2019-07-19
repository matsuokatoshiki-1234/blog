class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  validates :body, presence: true, length: { maximum: 200 }
  validate :check_number_of_comments
  def check_number_of_comments
    if post && post.comments.count >= 10
      errors.add(:body, "数の上限に達したのでコメントできませんでした。")
    end
  end
end
