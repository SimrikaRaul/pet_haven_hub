module ApplicationHelper
  # Format request status with color-coded badge
  def status_badge(status)
    case status
    when 'open'
      tag.span('Open', class: 'px-3 py-1 rounded-full text-xs font-semibold text-white bg-yellow-500')
    when 'approved'
      tag.span('Approved', class: 'px-3 py-1 rounded-full text-xs font-semibold text-white bg-green-500')
    when 'rejected'
      tag.span('Rejected', class: 'px-3 py-1 rounded-full text-xs font-semibold text-white bg-red-500')
    when 'scheduled'
      tag.span('Scheduled', class: 'px-3 py-1 rounded-full text-xs font-semibold text-white bg-blue-500')
    when 'completed'
      tag.span('Completed', class: 'px-3 py-1 rounded-full text-xs font-semibold text-white bg-gray-600')
    else
      tag.span(status&.titleize, class: 'px-3 py-1 rounded-full text-xs font-semibold text-white bg-gray-400')
    end
  end

  # Format request type
  def request_type_label(type)
    case type
    when 'adopt'
      tag.span('🏠 Adoption', class: 'inline-block px-2 py-1 bg-blue-100 text-blue-700 rounded text-sm font-semibold')
    when 'donate'
      tag.span('💝 Donation', class: 'inline-block px-2 py-1 bg-purple-100 text-purple-700 rounded text-sm font-semibold')
    else
      tag.span(type&.titleize)
    end
  end

  # Format pet type with emoji
  def pet_type_icon(pet_type)
    case pet_type.to_s
    when 'dog'
      '🐕'
    when 'cat'
      '🐈'
    when 'rabbit'
      '🐰'
    when 'bird'
      '🦜'
    else
      '🐾'
    end
  end

  # Format pet size
  def size_label(size)
    case size
    when 'small'
      'Small (< 10 kg)'
    when 'medium'
      'Medium (10-25 kg)'
    when 'large'
      'Large (> 25 kg)'
    else
      size&.titleize
    end
  end

  # Format pet health status
  def health_badge(health_status)
    case health_status.to_s.downcase
    when 'excellent'
      tag.span('Excellent', class: 'px-2 py-1 rounded text-xs font-semibold text-white bg-green-500')
    when 'good'
      tag.span('Good', class: 'px-2 py-1 rounded text-xs font-semibold text-white bg-blue-500')
    when 'fair'
      tag.span('Fair', class: 'px-2 py-1 rounded text-xs font-semibold text-white bg-yellow-500')
    when 'poor'
      tag.span('Poor', class: 'px-2 py-1 rounded text-xs font-semibold text-white bg-red-500')
    else
      tag.span(health_status&.titleize)
    end
  end

  # Time ago in words with styling
  def formatted_time_ago(time)
    tag.span(time_ago_in_words(time), class: 'text-gray-600 text-sm', title: time.to_formatted_s(:long))
  end

  # Display pagination links with Tailwind styling
  def pagination_links(collection)
    paginate(collection, views_prefix: 'kaminari')
  end

  # Format distance in kilometers
  def distance_label(distance_km)
    if distance_km
      "#{distance_km.round(2)} km"
    else
      'N/A'
    end
  end

  # User avatar placeholder
  def user_avatar(user, size = 'md')
    initials = user.full_name.split.map(&:first).join.upcase
    color_class = case (user.id % 5)
                  when 0 then 'bg-red-500'
                  when 1 then 'bg-blue-500'
                  when 2 then 'bg-green-500'
                  when 3 then 'bg-purple-500'
                  else 'bg-yellow-500'
                  end
    
    size_class = case size
                 when 'sm' then 'w-8 h-8 text-xs'
                 when 'md' then 'w-10 h-10 text-sm'
                 when 'lg' then 'w-16 h-16 text-lg'
                 else 'w-10 h-10 text-sm'
                 end
    
    tag.div(initials, class: "#{color_class} #{size_class} rounded-full flex items-center justify-center text-white font-bold")
  end

  # Flash message styling
  def flash_message(type, message)
    flash_class = case type
                  when 'notice' then 'bg-green-100 border border-green-400 text-green-700'
                  when 'alert' then 'bg-red-100 border border-red-400 text-red-700'
                  else 'bg-blue-100 border border-blue-400 text-blue-700'
                  end
    
    tag.div(message, class: "#{flash_class} px-4 py-3 rounded-lg mb-4")
  end

  # Star rating display
  def star_rating(rating, max = 5)
    filled = '★'.to_s * rating.to_i
    empty = '☆'.to_s * (max - rating.to_i)
    "#{filled}#{empty}"
  end

  # Determine if a link is active in admin navbar
  def active_link_helper(path)
    request.path == path || request.path.start_with?(path.sub(/\d+$/, '')) ? 'active' : ''
  end
end
