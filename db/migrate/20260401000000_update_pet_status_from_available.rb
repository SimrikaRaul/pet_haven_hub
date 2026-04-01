class UpdatePetStatusFromAvailable < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        # Update pet statuses based on the old 'available' boolean field
        execute("UPDATE pets SET status = 'available' WHERE status IS NULL AND available = true")
        execute("UPDATE pets SET status = 'adopted' WHERE status IS NULL AND available = false")
        
        # Set any remaining NULL statuses to 'available' (safest default)
        execute("UPDATE pets SET status = 'available' WHERE status IS NULL")
      end
      
      dir.down do
        # No downgrade needed - status field remains
      end
    end
  end
end
