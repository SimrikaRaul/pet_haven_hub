class AddRecommendationFieldsToPets < ActiveRecord::Migration[5.1]
  def change
    add_column :pets, :energy_level, :string
    add_column :pets, :apartment_friendly, :boolean, default: false
    add_column :pets, :kids_friendly, :boolean, default: false
  end
end
