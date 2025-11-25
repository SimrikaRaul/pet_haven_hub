class PetPresenter
  delegate :id, :name, :pet_type, :breed, :age, :size, :sex, :health_status, 
           :vaccinated, :description, :city, :country, :latitude, :longitude, to: :pet

  def initialize(pet)
    @pet = pet
  end

  def pet
    @pet
  end

  def display_name
    "#{pet_type_icon} #{name}"
  end

  def pet_type_icon
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

  def size_label
    case size.to_s
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

  def health_status_badge
    "<span class='badge badge-#{health_badge_class}'>#{health_status}</span>"
  end

  def age_display
    "#{age} year#{'s' unless age == 1}"
  end

  def vaccination_status
    vaccinated ? 'Vaccinated' : 'Not Vaccinated'
  end

  def availability_status
    pet.available? ? 'Available' : 'Adopted'
  end

  def location
    "#{city}, #{country}" if city && country
  end

  def pending_requests_count
    pet.requests.where(status: 'open').count
  end

  def adoption_requests_count
    pet.requests.where(request_type: 'adopt').count
  end

  def to_json(options = {})
    {
      id: pet.id,
      name: pet.name,
      pet_type: pet.pet_type,
      breed: pet.breed,
      age: pet.age,
      size: size_label,
      sex: sex,
      location: location,
      available: pet.available?
    }
  end

  private

  def health_badge_class
    case health_status&.downcase
    when 'excellent'
      'success'
    when 'good'
      'primary'
    when 'fair'
      'warning'
    when 'poor'
      'danger'
    else
      'primary'
    end
  end
end
