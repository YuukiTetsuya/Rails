class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }                                 # 並び順を降順に変更
  mount_uploader :picture, PictureUploader                                      # picture属性にPictureUploader（画像投稿gem）を渡す。
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size
end

  private

    # アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end