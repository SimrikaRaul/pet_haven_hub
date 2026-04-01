# Service for generating pet recommendations based on collaborative filtering.
class CollaborativeFilteringService
  DEFAULT_LIMIT = 8
  MIN_SIMILARITY_THRESHOLD = 0.1

  INTERACTION_WEIGHTS = {
    'view'     => 1,
    'like'     => 2,
    'wishlist' => 3,
    'adopt'    => 5
  }.freeze

  def initialize(user, limit: DEFAULT_LIMIT)
    @user = user
    @limit = limit
  end

  def call
    return [] if @user.nil?

    scored_pets = collaborative_recommendations
    scored_pets = popularity_fallback if scored_pets.empty?

    enrich_with_compatibility(scored_pets).first(@limit)
  end

  private

  # ── Core collaborative filtering ─────────────────────────────────────

  def collaborative_recommendations
    # Step 1: Get the current user's interactions (likes, wishlists, adoptions — weight >= 2)
    user_interactions = @user.interactions
                             .where("weight >= ?", 2)
                             .pluck(:pet_id, :weight)
                             .to_h

    return [] if user_interactions.empty?

    user_pet_ids = user_interactions.keys

    # Step 2: Find users who also interacted with those same pets
    similar_user_ids = Interaction.where(pet_id: user_pet_ids)
                                  .where.not(user_id: @user.id)
                                  .distinct
                                  .pluck(:user_id)

    return [] if similar_user_ids.empty?

    # Step 3: Score pets from similar users, weighted by similarity
    pet_scores = Hash.new(0.0)

    similar_user_ids.each do |uid|
      other_interactions = Interaction.where(user_id: uid)
                                      .where("weight >= ?", 2)
                                      .pluck(:pet_id, :weight)
                                      .to_h

      similarity = weighted_jaccard_similarity(user_interactions, other_interactions)
      next if similarity < MIN_SIMILARITY_THRESHOLD

      # Score pets this similar user liked that the current user hasn't seen
      other_interactions.each do |pid, weight|
        next if user_pet_ids.include?(pid)
        pet_scores[pid] += weight * similarity
      end
    end

    return [] if pet_scores.empty?

    # Step 4: Fetch top-scored available pets, preserving rank order
    ranked = pet_scores.sort_by { |_, score| -score }
                       .first(@limit)

    top_pet_ids = ranked.map(&:first)
    score_lookup = ranked.to_h

    excluded_ids = @user.pets.pluck(:id) # exclude user's own donated pets
    pets_by_id = Pet.available
                    .where(id: top_pet_ids)
                    .where.not(id: excluded_ids)
                    .index_by(&:id)

    top_pet_ids.filter_map do |id|
      next unless pets_by_id[id]

      {
        pet: pets_by_id[id],
        collaborative_score: score_lookup[id]&.round(4) || 0
      }
    end
  end

  # ── Popularity fallback ──────────────────────────────────────────────

  def popularity_fallback
    excluded_ids = @user.pets.pluck(:id)
    interacted_ids = @user.interactions.pluck(:pet_id).uniq

    pets = Pet.available
              .where.not(id: excluded_ids + interacted_ids)
              .left_joins(:interactions)
              .group("pets.id")
              .order("COUNT(interactions.id) DESC")
              .limit(@limit)
              .to_a

    pets.map { |pet| { pet: pet, collaborative_score: 0 } }
  end

  # ── Compatibility enrichment ─────────────────────────────────────────

  def enrich_with_compatibility(scored_pets)
    scored_pets.map do |entry|
      svc = CompatibilityScoringService.new(@user, entry[:pet])

      entry.merge(
        compatibility_score: svc.calculate_score,
        explanation: svc.generate_explanation
      )
    end
  end

  # ── Similarity calculation ───────────────────────────────────────────

  def weighted_jaccard_similarity(weights_a, weights_b)
    common_pets = weights_a.keys & weights_b.keys
    return 0.0 if common_pets.empty?

    intersection = common_pets.sum { |pid| [weights_a[pid], weights_b[pid]].min }
    union = (weights_a.keys | weights_b.keys).sum do |pid|
      [weights_a[pid] || 0, weights_b[pid] || 0].max
    end

    union.zero? ? 0.0 : (intersection.to_f / union).round(4)
  end
end
