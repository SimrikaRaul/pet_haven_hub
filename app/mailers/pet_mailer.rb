class PetMailer < ApplicationMailer
  def status_changed(pet, previous_status, new_status)
    @pet = pet
    @previous_status = previous_status
    @new_status = new_status

    recipients = []
    recipients << @pet.user.email if @pet.user&.email.present?

    # Notify open adoption requesters
    requester_emails = @pet.requests.where(request_type: 'adopt', status: 'open').joins(:user).pluck('users.email')
    recipients.concat(requester_emails)

    recipients.compact!.uniq!
    return if recipients.blank?

    mail(
      to: recipients,
      subject: "#{@pet.name} status updated to #{@new_status.titleize}"
    )
  end
end
