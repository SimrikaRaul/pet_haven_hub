class AddAdoptionDateAndAdminNoteToRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :requests, :adoption_date, :date, comment: "Scheduled pickup date for approved adoption requests"
    add_column :requests, :admin_note, :text, comment: "Admin instructions and notes for the approved request"
    
    # Add index for querying by adoption_date (useful for capacity checking)
    add_index :requests, :adoption_date, where: "status = 'approved'"
  end
end
