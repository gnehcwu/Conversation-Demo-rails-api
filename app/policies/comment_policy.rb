class CommentPolicy < ApplicationPolicy
  def show?
    return true
  end

  def create?
    return true if user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
