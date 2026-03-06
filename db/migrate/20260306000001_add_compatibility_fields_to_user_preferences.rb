class AddCompatibilityFieldsToUserPreferences < ActiveRecord::Migration[5.1]
  def change
    add_column :user_preferences, :living_space, :integer, default: 0, null: false
    add_column :user_preferences, :experience_level, :integer, default: 0, null: false
    add_column :user_preferences, :activity_level, :integer, default: 0, null: false
    add_column :user_preferences, :has_children, :boolean, default: false, null: false
  end
end
