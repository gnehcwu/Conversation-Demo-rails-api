class Api::V1::ConversationSerializer < Api::V1::BaseSerializer
  attributes :id, :title, :content, :created_at, :updated_at

  embed :ids
  has_one :user
  has_many :comments
end

