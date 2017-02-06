class Comment < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  default_scope -> { order('created_at DESC') }

  validates :content, presence: true, length: {minimum: 10}
end
