class RecommendationRefreshJob < ApplicationJob
  queue_as :default

  def perform(user_id = nil)
    if user_id
      user = User.find_by(id: user_id)
      return unless user
      # compute and cache recommendations for a single user
      recs = Recommendations::ContentBasedService.new(user: user).call
      Rails.cache.write("user:#{user.id}:recommendations", recs.map(&:id), expires_in: 6.hours)
    else
      # refresh for all active users (naive implementation)
      User.find_each do |u|
        recs = Recommendations::ContentBasedService.new(user: u).call
        Rails.cache.write("user:#{u.id}:recommendations", recs.map(&:id), expires_in: 6.hours)
      end
    end
  end
end
