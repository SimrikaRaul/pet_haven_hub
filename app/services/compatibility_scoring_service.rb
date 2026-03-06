
class CompatibilityScoringService
  WEIGHTS = {
    space:      30,
    experience: 25,
    activity:   20,
    family:     25
  }.freeze

  def initialize(user, pet)
    @user = user
    @pet  = pet
    @preference = user.user_preference
  end

  # Returns an Integer score between 0 and 100.
  def calculate_score
    return 0 unless @preference

    total = space_match_score +
            experience_match_score +
            activity_match_score +
            family_match_score

    total.clamp(0, 100)
  end

 
  def space_match_score
    return 0 unless @preference.living_space.present?

    case @preference.living_space
    when 'apartment'
      @pet.apartment_friendly? ? WEIGHTS[:space] : (WEIGHTS[:space] * 0.2).round
    when 'house'
      if @pet.apartment_friendly?
        # Pet is fine in smaller spaces, so a house is more than enough
        WEIGHTS[:space]
      else
        # Pet needs space — a house is a reasonable fit
        (WEIGHTS[:space] * 0.8).round
      end
    when 'farm'
      # A farm can accommodate any pet comfortably
      WEIGHTS[:space]
    else
      0
    end
  end


  def experience_match_score
    return 0 unless @preference.experience_level.present?
    return 0 unless @pet.trainability.present?

    exp_rank   = experience_rank(@preference.experience_level)
    train_rank = trainability_rank(@pet.trainability)

    diff = exp_rank - train_rank # positive = user is over-qualified

    if diff >= 0
      # User meets or exceeds the requirement
      WEIGHTS[:experience]
    elsif diff == -1
      # Slightly under-qualified
      (WEIGHTS[:experience] * 0.5).round
    else
      # Significantly under-qualified
      (WEIGHTS[:experience] * 0.2).round
    end
  end

 
  def activity_match_score
    return 0 unless @preference.activity_level.present?
    return 0 unless @pet.energy_level.present?

    user_rank = level_rank(@preference.activity_level)
    pet_rank  = level_rank(@pet.energy_level)
    diff      = (user_rank - pet_rank).abs

    case diff
    when 0 then WEIGHTS[:activity]                          # exact match
    when 1 then (WEIGHTS[:activity] * 0.6).round            # close match
    else        (WEIGHTS[:activity] * 0.2).round            # poor match
    end
  end

 
  def family_match_score
    return WEIGHTS[:family] unless @preference.has_children?

    # User has children — kids_friendly becomes critical
    @pet.kids_friendly? ? WEIGHTS[:family] : (WEIGHTS[:family] * 0.1).round
  end

  # Returns an Array of 2–4 human-readable strings explaining the compatibility.
  def generate_explanation
    return [] unless @preference

    reasons = []
    reasons << space_explanation
    reasons << family_explanation
    reasons << activity_explanation
    reasons << experience_explanation
    reasons.compact.first(4).tap { |r| r.slice!(0...-2) if r.size < 2 }
    reasons.compact.first(4)
  end

  private


  def space_explanation
    return nil unless @preference.living_space.present?

    case @preference.living_space
    when 'apartment'
      if @pet.apartment_friendly?
        "Suitable for apartment living"
      else
        "This pet may need more space than an apartment provides"
      end
    when 'house'
      "Well-suited for a house environment"
    when 'farm'
      "Great fit for a spacious farm setting"
    end
  end

  def family_explanation
    if @preference.has_children?
      if @pet.kids_friendly?
        "Good match for families with children"
      else
        "May not be ideal for households with young children"
      end
    else
      nil # No children constraint — skip rather than add filler
    end
  end

  def activity_explanation
    return nil unless @preference.activity_level.present? && @pet.energy_level.present?

    user_rank = level_rank(@preference.activity_level)
    pet_rank  = level_rank(@pet.energy_level)
    diff      = (user_rank - pet_rank).abs

    case diff
    when 0
      "Matches your activity level"
    when 1
      "Close to your preferred activity level"
    else
      "Activity level differs significantly from your preference"
    end
  end

  def experience_explanation
    return nil unless @preference.experience_level.present? && @pet.trainability.present?

    exp_rank   = experience_rank(@preference.experience_level)
    train_rank = trainability_rank(@pet.trainability)
    diff       = exp_rank - train_rank

    if diff >= 0
      case @pet.trainability
      when 'easy'   then "Beginner-friendly pet"
      when 'medium' then "Suitable for your experience level"
      when 'hard'   then "A rewarding challenge for an experienced owner"
      end
    elsif diff == -1
      "May require a bit more experience than expected"
    else
      "This pet needs an experienced handler"
    end
  end

  # Maps experience level string to a numeric rank (1-3).
  def experience_rank(level)
    case level.to_s
    when 'beginner'     then 1
    when 'intermediate' then 2
    when 'expert'       then 3
    else 0
    end
  end

  # Maps trainability string to a numeric rank (1-3).
  def trainability_rank(level)
    case level.to_s
    when 'easy'   then 1
    when 'medium' then 2
    when 'hard'   then 3
    else 0
    end
  end

  # Maps a low/medium/high string to a numeric rank (1-3).
  def level_rank(level)
    case level.to_s
    when 'low'    then 1
    when 'medium' then 2
    when 'high'   then 3
    else 0
    end
  end
end
