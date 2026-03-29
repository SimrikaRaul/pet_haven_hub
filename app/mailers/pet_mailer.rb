# app/mailers/pet_mailer.rb
class PetMailer < ApplicationMailer

  # Sent to pet owner + pending adopters when pet status changes
  def status_changed(pet, previous_status, new_status)
    @pet             = pet
    @previous_status = previous_status
    @new_status      = new_status

    recipients = []

    # Notify the pet's owner
    recipients << pet.user.email if pet.user&.email.present?

    # Notify users with pending adoption requests for this pet
    # Fixed: use 'pending' not 'open' (matches your schema status values)
    requester_emails = pet.requests
                          .where(request_type: 'adopt', status: 'pending')
                          .joins(:user)
                          .pluck('users.email')

    recipients.concat(requester_emails)
    recipients.compact!
    recipients.uniq!

    return if recipients.blank?

    mail(
      to:      recipients,
      subject: "#{pet.name}'s Status Has Been Updated | #{APP_NAME}"
    )
  end
end