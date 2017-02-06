class Api::V1::ConversationsController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:index, :update, :destroy]

  def index
    conversations = Conversation.where(user_id: params[:user_id])
    conversations = apply_filters(conversations, params)
    conversations = paginate(conversations)
    conversations = policy_scope(conversations)

    render(
      json: ActiveModel::ArraySerializer.new(
          conversations,
          each_serializer: Api::V1::ConversationSerializer,
          root: 'conversations'
      )
    )
  end

  def recent
    conversations = Conversation.order("created_at desc").limit(10)

    render(
      json: ActiveModel::ArraySerializer.new(
        conversations,
        each_serializer: Api::V1::ConversationSerializer,
        root: 'conversations',
      )
    )
  end

  def show
    conversation = Conversation.find(params[:id])
    authorize conversation

    render json: Api::V1::ConversationSerializer.new(conversation).to_json
  end

  def create
    conversation = Conversation.new(create_params)
    return api_error(status: 422, errors: conversation.errors) unless conversation.valid?

    conversation.save!

    render(
      json: Api::V1::ConversationSerializer.new(conversation).to_json,
      status: 201,
      location: api_v1_conversation_path(conversation.id),
      serializer: Api::V1::ConversationSerializer
    )
  end

  def update
    conversation = Conversation.find(params[:id])

    authorize conversation

    unless conversation.update_attributes(update_params)
      return api_error(status: 422, errors: conversation.errors)
    end

    render(
      json: Api::V1::ConversationSerializer.new(conversation).to_json,
      status: 200,
      location: api_v1_conversation_path(conversation.id),
      serializer: Api::V1::ConversationSerializer
    )
  end

  def destroy
    conversation = Conversation.find(params[:id])

    authorize conversation

    unless conversation.destroy
      return api_error(status: 500)
    end

    head status: 204
  end

  private
    def create_params
      params.require(:conversation).permit(
          :title, :content, :user_id
      ).delete_if{ |k,v| v.nil? }
    end
    def update_params
      create_params
    end
end

