
class CollaborativeRecommendationService
  DEFAULT_LIMIT = 5

  def initialize(user, limit: DEFAULT_LIMIT)
    @user = user
    @limit = limit
  end

  def call
 
    return [] unless @user

    scores = Hash.new(0.0)
    add_similar_user_pet_scores(scores)
    add_co_requested_pet_scores(scores)
    add_preference_neighbor_scores(scores)
    excluded_pet_ids = excluded_ids
    scores.reject! { |pid, _| excluded_pet_ids.include?(pid) }
    return [] if scores.empty?
    top_pet_ids = scores.sort_by { |_, s| -s }.first(@limit).map(&:first)
    pets_by_id = Pet.where(id: top_pet_ids, available: true).index_by(&:id)
    top_pet_ids.filter_map { |pid| pets_by_id[pid] }
  end

  private


  def add_similar_user_pet_scores(scores)
 
    my_pet_ids = user_requested_pet_ids
    return if my_pet_ids.empty?


    similar_user_ids = Request.where(pet_id: my_pet_ids)
                              .where.not(user_id: @user.id)
                              .distinct
                              .pluck(:user_id)
    return if similar_user_ids.empty?


    overlap_counts = Request.where(user_id: similar_user_ids, pet_id: my_pet_ids)
                            .group(:user_id)
                            .count 

    
    Request.where(user_id: similar_user_ids)
           .where.not(pet_id: my_pet_ids)
           .pluck(:user_id, :pet_id)
           .each do |uid, pid|
      overlap = overlap_counts[uid] || 1
      scores[pid] += 3.0 * overlap
    end
  end


  def add_co_requested_pet_scores(scores)
    my_pet_ids = user_requested_pet_ids
    return if my_pet_ids.empty?
    co_users = Request.where(pet_id: my_pet_ids)
                      .where.not(user_id: @user.id)
                      .distinct
                      .pluck(:user_id)
    return if co_users.empty?
    Request.where(user_id: co_users)
           .where.not(pet_id: my_pet_ids)
           .group(:pet_id)
           .count
           .each do |pid, cnt|
      scores[pid] += 2.0 * Math.log(cnt + 1)
    end
  end

  def add_preference_neighbor_scores(scores)
    my_pref = @user.user_preference
    return unless my_pref
    neighbor_prefs = UserPreference.where.not(user_id: @user.id).includes(:user)
    return if neighbor_prefs.empty?

    neighbor_prefs.each do |np|
      similarity = preference_similarity(my_pref, np)
      next if similarity < 0.4 
      Request.where(user_id: np.user_id).pluck(:pet_id).each do |pid|
        scores[pid] += 1.5 * similarity
      end
    end
  end

  def preference_similarity(pref_a, pref_b)
    matches = 0.0
    total   = 0.0
    %i[preferred_energy_level preferred_grooming_needs preferred_exercise_needs].each do |attr|
      a = pref_a.public_send(attr)
      b = pref_b.public_send(attr)
      next if a.blank? || b.blank?

      total += 1
      diff = (level_score(a) - level_score(b)).abs
      matches += 1.0 - (diff / 2.0) # 0, 0.5, or 1
    end

    # Temperament
    if pref_a.preferred_temperament.present? && pref_b.preferred_temperament.present?
      total += 1
      matches += 1 if pref_a.preferred_temperament == pref_b.preferred_temperament
    end

    # Boolean attributes
    %i[wants_affectionate_pet apartment_friendly_required kids_in_home has_other_pets].each do |attr|
      total += 1
      matches += 1 if pref_a.public_send(attr) == pref_b.public_send(attr)
    end

    total.zero? ? 0.0 : (matches / total).round(4)
  end

  def level_score(level)
    case level
    when 'low'    then 1
    when 'medium' then 2
    when 'high'   then 3
    else 0
    end
  end

  def user_requested_pet_ids
    @user_requested_pet_ids ||= @user.requests.pluck(:pet_id).uniq
  end

  def excluded_ids
    @excluded_ids ||= begin
      own_pet_ids = @user.pets.pluck(:id)
      requested_ids = user_requested_pet_ids
      (own_pet_ids + requested_ids).uniq
    end
  end
end
