class CreateUserPreferences < ActiveRecord::Migration[5.1]
  def change
    create_table :user_preferences do |t|
      t.references :user, foreign_key: true, index: { unique: true }
      t.string :preferred_energy_level
      t.string :preferred_temperament
      t.string :preferred_grooming_needs
      t.string :preferred_exercise_needs
      t.boolean :wants_affectionate_pet, default: false
      t.boolean :apartment_friendly_required, default: false
      t.boolean :kids_in_home, default: false
      t.boolean :has_other_pets, default: false

      t.timestamps
    end
  end
end
