class Api::V1::CommentsController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:show, :create]

  def index
    comments = Comment.where(conversation_id: params[:conversation_id])
    comments = apply_filters(comments, params)
    comments = paginate(comments)
    comments = policy_scope(comments)

    render(
        json: ActiveModel::ArraySerializer.new(
            comments,
            each_serializer: Api::V1::CommentSerializer,
            root: 'comments',
            meta: meta_attributes(comments)
        )
    )
  end

  def show
    comment = Comment.find(params[:id])
    authorize comment

    render json: Api::V1::CommentSerializer.new(comment).to_json
  end

  def create
    comment = Comment.new(create_params)
    return api_error(status: 422, errors: comment.errors) unless comment.valid?

    comment.save!

    render(
        json: Api::V1::CommentSerializer.new(comment).to_json,
        status: 201,
        location: api_v1_comment_path(comment.id),
        serializer: Api::V1::CommentSerializer
    )
  end

  private
    def create_params
      params.require(:comment).permit(
          :content, :commenter, :conversation_id
      ).delete_if{ |k,v| v.nil? }
    end
end
