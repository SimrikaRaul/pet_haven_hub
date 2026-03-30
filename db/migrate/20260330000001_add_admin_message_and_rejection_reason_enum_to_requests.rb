class AddAdminMessageAndRejectionReasonEnumToRequests < ActiveRecord::Migration[8.1]
  def change
    # Add admin_message for custom rejection message
    unless column_exists?(:requests, :admin_message)
      add_column :requests, :admin_message, :text, comment: "Admin's custom message to user when rejecting request"
    end

    # Add rejection_reason_enum for structured rejection reasons
    unless column_exists?(:requests, :rejection_reason_enum)
      add_column :requests, :rejection_reason_enum, :string, comment: "Enum value for rejection reason"
    end
  end
end
