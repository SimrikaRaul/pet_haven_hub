module AuthenticationHelper
  
  def user_role_badge(user)
    return unless user
    
    case user.role
    when 'admin'
      tag.span('Admin', class: 'px-3 py-1 rounded-full text-xs font-bold text-white bg-red-600')
    when 'shelter_manager'
      tag.span('Shelter Manager', class: 'px-3 py-1 rounded-full text-xs font-bold text-white bg-blue-600')
    else
      tag.span('User', class: 'px-3 py-1 rounded-full text-xs font-bold text-white bg-gray-500')
    end
  end

 
  def current_user?(user)
    user_signed_in? && current_user.id == user.id
  end

  
  def can_edit?(resource)
    return false unless user_signed_in?
    admin_user? || (resource.respond_to?(:user_id) && resource.user_id == current_user.id)
  end

  
  def admin_dashboard_link
    return unless admin_user?
    link_to 'Admin Dashboard', admin_dashboard_path, class: 'admin-link'
  end

  #
  def user_greeting
    if user_signed_in?
      "Welcome back, #{current_user.name}!"
    else
      "Welcome to Pet Haven Hub"
    end
  end
end
