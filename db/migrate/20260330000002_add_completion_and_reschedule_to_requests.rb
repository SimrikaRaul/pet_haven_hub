class AddCompletionAndRescheduleToRequests < ActiveRecord::Migration[8.1]
  def change
    # Add timestamp for when adoption was completed
    unless column_exists?(:requests, :completed_at)
      add_column :requests, :completed_at, :datetime, comment: "Timestamp when adoption was completed"
    end

    # Add counter for reschedule attempts (max 2)
    unless column_exists?(:requests, :reschedule_count)
      add_column :requests, :reschedule_count, :integer, default: 0, comment: "Number of times request was rescheduled (max 2)"
    end

    # Update status enum to include no_show
    # Since we can't directly modify enum in migration, we'll do this via raw SQL before updating the model
    # The model will handle the no_show status automatically
  end
end
