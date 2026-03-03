# HybridRecommendationService
# Combines content-based and collaborative filtering for pet recommendations.
# Uses weighted formula: final_score = (0.6 * content_score) + (0.4 * collaborative_score)
#
# Features:
# - Excludes adopted pets
# - Excludes pets user has already interacted with (optional)
# - Debug logging for verification
# - Recommendations differ per user based on their interactions
#
# Console usage:
#   HybridRecommendationService.new(User.first).recommend
#   HybridRecommendationService.new(User.first, debug: true).recommend
#
class HybridRecommendationService
  # Weights for combining scores
  CONTENT_WEIGHT = 0.6
  COLLABORATIVE_WEIGHT = 0.4
  
  INTERACTION_WEIGHTS = {
    'view' => 1,
    'like' => 2,
    'wishlist' => 3,
    'adopt' => 5
  }.freeze

  DEFAULT_LIMIT = 10

  def initialize(user, limit: DEFAULT_LIMIT, debug: false, exclude_interacted: false)
    @user = user
    @limit = limit
    @debug = debug
    @exclude_interacted = exclude_interacted
    @logger = Rails.logger
  end


  def recommend
    log_header
    return fallback_recommendations if @user.nil?
    
  
    available_pets = Pet.where(available: true).where.not(status: 'adopted')
    log_debug "📊 Total available pets: #{available_pets.count}"
    
  
    excluded_ids = @user.pets.pluck(:id)
    log_debug "🚫 Excluding user's own pets: #{excluded_ids}" if excluded_ids.any?
    

    if @exclude_interacted
      interacted_ids = @user.interactions.pluck(:pet_id).uniq
      excluded_ids += interacted_ids
      log_debug "🚫 Excluding interacted pets: #{interacted_ids}" if interacted_ids.any?
    end
    
    candidate_pets = available_pets.where.not(id: excluded_ids)
    log_debug "🎯 Candidate pets for scoring: #{candidate_pets.count}"
    
    return fallback_recommendations if candidate_pets.empty?
    

    content_scores = calculate_content_scores(candidate_pets)
    collaborative_scores = calculate_collaborative_scores(candidate_pets)
    
 
    final_scores = combine_scores(candidate_pets, content_scores, collaborative_scores)
    
    
    sorted_pets = final_scores.sort_by { |_, score| -score }
    top_pet_ids = sorted_pets.first(@limit).map(&:first)
    
    log_final_results(top_pet_ids, final_scores)
    
 
    pets_by_id = Pet.where(id: top_pet_ids).index_by(&:id)
    recommended = top_pet_ids.filter_map { |id| pets_by_id[id] }
    

    if @debug
      recommended.map do |pet|
        {
          pet: pet,
          final_score: final_scores[pet.id],
          content_score: content_scores[pet.id] || 0,
          collaborative_score: collaborative_scores[pet.id] || 0
        }
      end
    else
      recommended
    end
  end

  # Alias for console testing
  alias_method :call, :recommend

  private

  def calculate_content_scores(pets)
    scores = {}
    pref = @user.user_preference
    nd return top recommendations
    log_debug "\n📝 CONTENT-BASED SCORING"
    
    unless pref
      log_debug "⚠️  No user preferences found - using default content scoring"
      pets.each { |pet| scores[pet.id] = default_content_score(pet) }
      return normalize_scores(scores)
    end
    
    pets.each do |pet|
      score = 0.0
      
     
      if pref.preferred_energy_level.present? && pet.energy_level.present?
        score += level_match_score(pref.preferred_energy_level, pet.energy_level) * 3
      end
      
    
      if pref.preferred_temperament.present? && pet.temperament.present?
        score += (pref.preferred_temperament == pet.temperament ? 3 : 0)
      end
      
    
      if pref.preferred_grooming_needs.present? && pet.grooming_needs.present?
        score += level_match_score(pref.preferred_grooming_needs, pet.grooming_needs) * 2
      end
      

      if pref.preferred_exercise_needs.present? && pet.exercise_needs.present?
        score += level_match_score(pref.preferred_exercise_needs, pet.exercise_needs) * 2
      end
      
   
      score += 1 if pref.wants_affectionate_pet && pet.affectionate
      score += 1 if pref.apartment_friendly_required && pet.apartment_friendly
      score += 1 if pref.kids_in_home && pet.kids_friendly
      score += 1 if pref.has_other_pets && pet.social_with_other_pets
  
      if @user.preferred_species.present? && pet.pet_type == @user.preferred_species
        score += 5
      end
      
      scores[pet.id] = score
    end
    
    log_top_scores("Content", scores, 5)
    normalize_scores(scores)
  end

  def calculate_collaborative_scores(pets)
    scores = Hash.new(0.0)
    
    log_debug "\n🤝 COLLABORATIVE FILTERING SCORING"
    

    user_interactions = @user.interactions.high_engagement.pluck(:pet_id, :weight).to_h
    log_debug "👤 User interactions (high engagement): #{user_interactions.count}"
    
    if user_interactions.empty?
      log_debug "⚠️  No user interactions found - collaborative scores will be zero"
      log_debug "💡 SUGGESTION: Create test interactions with:"
      log_debug "   Interaction.record_like(User.first, Pet.first)"
      log_debug "   Interaction.record_wishlist(User.first, Pet.second)"
      return scores
    end
    

    user_pet_ids = user_interactions.keys
    similar_user_ids = Interaction.where(pet_id: user_pet_ids)
                                  .where.not(user_id: @user.id)
                                  .distinct
                                  .pluck(:user_id)
    
    log_debug "🔍 Similar users found: #{similar_user_ids.count}"
    
    if similar_user_ids.empty?
      log_debug "⚠️  No similar users found - need more users with shared pet interactions"
      log_debug "💡 SUGGESTION: Create another user and add interactions:"
      log_debug "   u2 = User.second"
      log_debug "   Interaction.record_like(u2, Pet.first)"
      return scores
    end
    
   
    similar_user_ids.each do |uid|
      other_interactions = Interaction.where(user_id: uid).pluck(:pet_id, :weight).to_h
      similarity = calculate_user_similarity(user_interactions, other_interactions)
      
      next if similarity < 0.1 
      
   
      other_interactions.each do |pid, weight|
        next if user_pet_ids.include?(pid) 
        scores[pid] += weight * similarity
      end
    end
    
    log_top_scores("Collaborative", scores, 5)
    normalize_scores(scores)
  end

  def calculate_user_similarity(weights_a, weights_b)
    common_pets = weights_a.keys & weights_b.keys
    return 0.0 if common_pets.empty?

  
    intersection = common_pets.sum { |pid| [weights_a[pid], weights_b[pid]].min }
    union = (weights_a.keys | weights_b.keys).sum do |pid|
      [weights_a[pid] || 0, weights_b[pid] || 0].max
    end

    union.zero? ? 0.0 : (intersection.to_f / union).round(4)
  end

  def combine_scores(pets, content_scores, collaborative_scores)
    final_scores = {}
    
    log_debug "\n🔀 COMBINING SCORES (#{CONTENT_WEIGHT * 100}% content + #{COLLABORATIVE_WEIGHT * 100}% collaborative)"
    
    pets.each do |pet|
      content = content_scores[pet.id] || 0
      collaborative = collaborative_scores[pet.id] || 0
      final_scores[pet.id] = (CONTENT_WEIGHT * content) + (COLLABORATIVE_WEIGHT * collaborative)
    end
    
    final_scores
  end

  def normalize_scores(scores)
    return scores if scores.empty?
    
    max_score = scores.values.max.to_f
    return scores if max_score.zero?
    
    scores.transform_values { |v| (v / max_score * 100).round(2) }
  end

  def level_match_score(preferred, actual)
    levels = %w[low medium high]
    pref_idx = levels.index(preferred.to_s.downcase) || 1
    actual_idx = levels.index(actual.to_s.downcase) || 1
    
    diff = (pref_idx - actual_idx).abs
    case diff
    when 0 then 1.0
    when 1 then 0.5
    else 0.0
    end
  end

  def default_content_score(pet)
    score = 0.0
    score += 2 if pet.created_at > 14.days.ago  # Recency bonus
    score += 1 if pet.affectionate
    score += 1 if pet.apartment_friendly
    score
  end

  def fallback_recommendations
    log_debug "⚠️  Using fallback recommendations (random available pets)"
    Pet.where(available: true).order('RANDOM()').limit(@limit).to_a
  end


  def log_header
    return unless @debug
    
    log_debug "=" * 60
    log_debug "🐾 HYBRID RECOMMENDATION SERVICE"
    log_debug "=" * 60
    log_debug "👤 User: #{@user&.name || @user&.email || 'Anonymous'} (ID: #{@user&.id})"
    log_debug "📊 Total interactions in system: #{Interaction.count}"
    log_debug "👥 Users with interactions: #{Interaction.distinct.count(:user_id)}"
    log_debug "🐕 Pets with interactions: #{Interaction.distinct.count(:pet_id)}"
    
  
    breakdown = Interaction.group(:action).count
    log_debug "📈 Interaction breakdown: #{breakdown}"
  end

  def log_top_scores(type, scores, count)
    return unless @debug
    
    top = scores.sort_by { |_, v| -v }.first(count)
    log_debug "📊 Top #{count} #{type} scores:"
    top.each do |pet_id, score|
      pet = Pet.find_by(id: pet_id)
      log_debug "   - Pet ##{pet_id} (#{pet&.name}): #{score.round(2)}"
    end
  end

  def log_final_results(pet_ids, scores)
    return unless @debug
    
    log_debug "\n" + "=" * 60
    log_debug "🏆 FINAL RECOMMENDATIONS"
    log_debug "=" * 60
    
    pet_ids.each_with_index do |pid, idx|
      pet = Pet.find_by(id: pid)
      log_debug "#{idx + 1}. Pet ##{pid} (#{pet&.name}) - Score: #{scores[pid]&.round(2)}"
    end
    
    if pet_ids.empty?
      log_debug "⚠️  No recommendations generated!"
      log_debug "💡 Possible reasons:"
      log_debug "   - No available pets"
      log_debug "   - No user preferences set"
      log_debug "   - No interactions in the system"
    end
  end

  def log_debug(message)
    if @debug
      puts message
      @logger.info("[HybridRecommendation] #{message}")
    end
  end


  class << self
    def test(user = nil, debug: true)
      user ||= User.first
      puts "\n🧪 Testing HybridRecommendationService for #{user&.email || 'no user'}"
      puts "-" * 60
      
      service = new(user, debug: debug, limit: 5)
      results = service.recommend
      
      puts "\n📋 RESULTS SUMMARY:"
      if results.is_a?(Array) && results.first.is_a?(Hash)
        results.each_with_index do |item, idx|
          pet = item[:pet]
          puts "#{idx + 1}. #{pet.name} (#{pet.breed}) - Final: #{item[:final_score]&.round(2)}"
          puts "   Content: #{item[:content_score]&.round(2)}, Collaborative: #{item[:collaborative_score]&.round(2)}"
        end
      else
        results.each_with_index do |pet, idx|
          puts "#{idx + 1}. #{pet.name} (#{pet.breed})"
        end
      end
      
      results
    end

    def seed_test_data
      puts "🌱 Creating test interaction data..."
      
      users = User.limit(3).to_a
      pets = Pet.limit(10).to_a
      
      if users.count < 2
        puts "⚠️  Need at least 2 users. Create more users first."
        return
      end
      
      if pets.count < 5
        puts "⚠️  Need at least 5 pets. Create more pets first."
        return
      end
      
  
      Interaction.record_like(users[0], pets[0])
      Interaction.record_like(users[0], pets[1])
      Interaction.record_like(users[0], pets[2])
      Interaction.record_wishlist(users[0], pets[3])
      
    
      if users[1]
        Interaction.record_like(users[1], pets[0])
        Interaction.record_like(users[1], pets[1])
        Interaction.record_like(users[1], pets[4]) if pets[4]
        Interaction.record_wishlist(users[1], pets[5]) if pets[5]
      end
      
  
      if users[2]
        Interaction.record_like(users[2], pets[3])
        Interaction.record_like(users[2], pets[6]) if pets[6]
      end
      
      puts "✅ Test data created!"
      puts "   Total interactions: #{Interaction.count}"
      puts "   Run: HybridRecommendationService.test to verify"
    end
  end
end
