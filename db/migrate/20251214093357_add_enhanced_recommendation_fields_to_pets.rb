class AddEnhancedRecommendationFieldsToPets < ActiveRecord::Migration[5.1]
  def change
    add_column :pets, :affectionate, :boolean, default: false
    add_column :pets, :temperament, :string
    add_column :pets, :social_with_other_pets, :boolean, default: false
    add_column :pets, :social_with_children, :boolean, default: false
    add_column :pets, :trainability, :string
    add_column :pets, :grooming_needs, :string
    add_column :pets, :exercise_needs, :string
  end
end
