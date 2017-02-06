class Conversation < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  belongs_to :user

  default_scope -> { order('created_at DESC') }

  validates :title, presence: true
  validates :content, presence: true
end
