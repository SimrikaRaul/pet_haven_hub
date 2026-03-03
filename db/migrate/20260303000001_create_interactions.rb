class CreateInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :interactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pet, null: false, foreign_key: true
      t.string :action, null: false
      t.integer :weight, null: false, default: 1

      t.timestamps
    end

    # Ensure one user cannot perform duplicate actions on the same pet
    add_index :interactions, [:user_id, :pet_id, :action], unique: true, name: 'index_interactions_uniqueness'
    
    # Index for efficient querying by action type
    add_index :interactions, :action
    
    # Index for collaborative filtering queries
    add_index :interactions, [:pet_id, :weight]
  end
end
