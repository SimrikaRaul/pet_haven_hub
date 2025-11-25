class RequestPolicy < ApplicationPolicy
  def show?
    user && (admin? || record.user_id == user.id)
  end

  def create?
    user.present?
  end

  def approve?
    admin?
  end

  def reject?
    admin?
  end
end
