class PetHavenMailer
  def self.adoption_approved_email(adoption_request, pickup_date = nil)
    to = adoption_request.user.email
    user = adoption_request.user
    pet = adoption_request.pet
    pickup_date ||= adoption_request.adoption_date
    
    subject = "🎉 Congratulations! Your Adoption for #{pet.name} Has Been Approved! 🐾"
    pickup_date_display = pickup_date.present? ? pickup_date.strftime('%B %d, %Y') : 'To be scheduled'
    
    html_body = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f9f5f0; }
          .container { max-width: 650px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); overflow: hidden; }
          .header { background: linear-gradient(135deg, #10B981 0%, #059669 100%); padding: 50px 30px; text-align: center; color: white; }
          .header h1 { margin: 0; font-size: 32px; font-weight: 700; letter-spacing: -0.5px; }
          .header p { margin: 8px 0 0 0; font-size: 16px; opacity: 0.95; }
          .content { padding: 50px 30px; }
          .message { font-size: 16px; color: #333333; line-height: 1.7; margin: 0 0 28px 0; }
          .pet-badge { background: #f0fdf4; border-left: 4px solid #10B981; padding: 24px; border-radius: 8px; margin: 28px 0; }
          .pet-badge h3 { color: #10B981; margin: 0 0 16px 0; font-size: 16px; }
          .detail-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #e5e7eb; font-size: 15px; }
          .detail-label { color: #666666; font-weight: 600; }
          .detail-value { color: #333333; font-weight: 500; }
          .detail-row:last-child { border-bottom: none; }
          .adoption-charge { background: #fff8e1; border-left: 4px solid #f59e0b; padding: 20px; border-radius: 8px; margin: 28px 0; }
          .adoption-charge h4 { color: #d97706; margin: 0 0 12px 0; font-size: 15px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600; }
          .adoption-charge p { color: #555555; margin: 0; font-size: 15px; line-height: 1.6; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #10B981 0%, #059669 100%); color: white; padding: 16px 48px; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 16px; margin: 32px 0; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3); text-align: center; }
          .next-steps { background: #f0fdf4; padding: 24px; border-radius: 8px; margin: 28px 0; }
          .next-steps h4 { color: #10B981; margin: 0 0 16px 0; font-size: 15px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600; }
          .next-steps ol { margin: 0; padding-left: 20px; color: #555555; font-size: 15px; line-height: 1.8; }
          .next-steps li { margin: 8px 0; }
          .footer { background-color: #f9f5f0; padding: 30px; text-align: center; border-top: 1px solid #eeeeee; }
          .footer-text { color: #888888; font-size: 13px; margin: 8px 0; }
          .footer-link { color: #10B981; text-decoration: none; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎉 Congratulations, #{user.name}! 🐾</h1>
            <p>Your adoption request has been approved!</p>
          </div>

          <div class="content">
            <p class="message">
              We're thrilled to inform you that your adoption request for <strong>#{pet.name}</strong> has been <strong>approved</strong>! 🐾💕
            </p>

            <div class="pet-badge">
              <h3>Your New Family Member</h3>
              <div class="detail-row">
                <span class="detail-label">Pet Name:</span>
                <span class="detail-value">#{pet.name}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Breed:</span>
                <span class="detail-value">#{pet.breed || 'Mixed'}</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Age:</span>
                <span class="detail-value">#{pet.age} #{pet.age == 1 ? 'year' : 'years'} old</span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Type:</span>
                <span class="detail-value">#{pet.pet_type&.titleize || 'Pet'}</span>
              </div>
            </div>

            <div class="pet-badge">
              <h3>📅 Pickup Information</h3>
              <div class="detail-row">
                <span class="detail-label">Scheduled Pickup Date:</span>
                <span class="detail-value"><strong>#{pickup_date_display}</strong></span>
              </div>
              <div class="detail-row">
                <span class="detail-label">Status:</span>
                <span class="detail-value">✅ Approved & Ready</span>
              </div>
            </div>

            <div class="adoption-charge">
              <h4>💰 Adoption Charge</h4>
              <p>Please bring <strong>NPR 1,000</strong> as the adoption charge on your pickup date. This is a one-time fee that helps us continue our mission of rescuing and caring for pets.</p>
            </div>

            <div class="next-steps">
              <h4>📋 What's Next?</h4>
              <ol>
                <li><strong>Prepare your home:</strong> Set up a safe space for #{pet.name} with food, water, and a comfortable bed</li>
                <li><strong>Gather required documents:</strong> Bring valid ID and any other identification requested</li>
                <li><strong>Schedule pickup:</strong> We'll send you detailed instructions and confirm the exact time</li>
                <li><strong>Complete paperwork:</strong> Sign final adoption documents and pay the adoption charge (NPR 1,000)</li>
                <li><strong>Take #{pet.name} home:</strong> Welcome your new family member! 🏡💕</li>
              </ol>
            </div>

            <p class="message">
              We're so excited for you and #{pet.name}! This is the beginning of an amazing journey together. If you have any questions or need anything before pickup, don't hesitate to reach out.
            </p>

            <div style="text-align: center;">
              <a href="https://sijalneupane.tech/requests/#{adoption_request.id}" class="cta-button">View Adoption Details</a>
            </div>

            <p style="color: #888888; font-size: 13px; line-height: 1.6; margin: 32px 0 0 0; border-top: 1px solid #eeeeee; padding-top: 24px; text-align: center;">
              Thank you for choosing Pet Haven Hub and for giving #{pet.name} a loving forever home! 🏡
            </p>
          </div>

          <div class="footer">
            <p class="footer-text"><strong>© Pet Haven Hub</strong></p>
            <p class="footer-text">
              <a href="mailto:noreply@sijalneupane.tech" class="footer-link">noreply@sijalneupane.tech</a>
            </p>
            <p class="footer-text">Questions? Visit our website or reply to this email.</p>
          </div>
        </div>
      </body>
      </html>
    HTML

    from = 'Pet Haven Hub <noreply@sijalneupane.tech>'
    # ONLY send HTML version - no plain text to avoid duplicate emails
    SendEmailJob.perform_later(to, subject, nil, html_body, from)
  end

  # ===== ADOPTION REJECTION EMAIL =====
  # Sends HTML-only email with rejection reason
  def self.adoption_rejected_email(adoption_request, rejection_reason = nil)
    to = adoption_request.user.email
    user = adoption_request.user
    pet = adoption_request.pet
    reason_text = get_rejection_reason_text(adoption_request, rejection_reason)
    
    subject = "Update on Your Adoption Request for #{pet.name}"
    
    html_body = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f9f5f0; }
          .container { max-width: 650px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); overflow: hidden; }
          .header { background: linear-gradient(135deg, #8b7355 0%, #a68368 100%); padding: 50px 30px; text-align: center; color: white; }
          .header h1 { margin: 0; font-size: 32px; font-weight: 700; letter-spacing: -0.5px; }
          .header p { margin: 8px 0 0 0; font-size: 16px; opacity: 0.95; }
          .content { padding: 50px 30px; }
          .message { font-size: 16px; color: #333333; line-height: 1.7; margin: 0 0 28px 0; }
          .reason-box { background: #fef3e2; border-left: 4px solid #d4a574; padding: 24px; border-radius: 8px; margin: 28px 0; }
          .reason-box h3 { color: #8b7355; margin: 0 0 12px 0; font-size: 16px; font-weight: 600; }
          .reason-text { color: #555555; font-size: 15px; line-height: 1.7; margin: 0; }
          .encouragement-box { background: #f0f9ff; border-left: 4px solid #3b82f6; padding: 24px; border-radius: 8px; margin: 28px 0; }
          .encouragement-box h3 { color: #3b82f6; margin: 0 0 12px 0; font-size: 15px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
          .encouragement-text { color: #555555; font-size: 15px; line-height: 1.7; margin: 0; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #8b7355 0%, #a68368 100%); color: white; padding: 16px 48px; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 16px; margin: 32px 0; box-shadow: 0 4px 12px rgba(139, 115, 85, 0.3); text-align: center; }
          .next-steps { background: #fef3e2; padding: 24px; border-radius: 8px; margin: 28px 0; }
          .next-steps h4 { color: #8b7355; margin: 0 0 16px 0; font-size: 15px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600; }
          .next-steps ul { margin: 0; padding-left: 20px; color: #555555; font-size: 15px; line-height: 1.8; }
          .next-steps li { margin: 8px 0; }
          .footer { background-color: #f9f5f0; padding: 30px; text-align: center; border-top: 1px solid #eeeeee; }
          .footer-text { color: #888888; font-size: 13px; margin: 8px 0; }
          .footer-link { color: #8b7355; text-decoration: none; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Update on Your Request</h1>
            <p>For #{pet.name}</p>
          </div>

          <div class="content">
            <p class="message">
              Hello <strong>#{user.name}</strong>,
            </p>

            <p class="message">
              Thank you for your interest in #{pet.name}. We truly appreciate the time and care you put into your adoption request.
            </p>

            <div class="reason-box">
              <h3>📋 Reason for Decision</h3>
              <p class="reason-text">
                #{reason_text}
              </p>
            </div>

            <div class="encouragement-box">
              <h3>💙 But Don't Lose Hope</h3>
              <p class="encouragement-text">
                This isn't the end of your adoption journey! There are many wonderful pets waiting to meet you. Each pet is unique, and we're confident you'll find the perfect match for your home and lifestyle.
              </p>
            </div>

            <div class="next-steps">
              <h4>🐾 What You Can Do Now</h4>
              <ul>
                <li><strong>Browse our available pets:</strong> Visit our site to explore other amazing animals looking for homes</li>
                <li><strong>Submit another request:</strong> If you find another pet that captures your heart, we'd love to help!</li>
                <li><strong>Get in touch:</strong> Our team is happy to discuss this decision or answer any questions</li>
                <li><strong>Refine your preferences:</strong> Tell us more about what you're looking for, and we'll help match you better</li>
              </ul>
            </div>

            <p class="message">
              We're here to support you on your adoption journey. Please don't give up—your perfect pet is waiting! 💕
            </p>

            <div style="text-align: center;">
              <a href="https://sijalneupane.tech/pets" class="cta-button">Browse Other Pets</a>
            </div>

            <p style="color: #888888; font-size: 13px; line-height: 1.6; margin: 32px 0 0 0; border-top: 1px solid #eeeeee; padding-top: 24px; text-align: center;">
              Questions? Our support team is here to help. Feel free to reply to this email anytime.
            </p>
          </div>

          <div class="footer">
            <p class="footer-text"><strong>© Pet Haven Hub</strong></p>
            <p class="footer-text">
              <a href="mailto:noreply@sijalneupane.tech" class="footer-link">noreply@sijalneupane.tech</a>
            </p>
            <p class="footer-text">We're here to support your adoption journey</p>
          </div>
        </div>
      </body>
      </html>
    HTML

    from = 'Pet Haven Hub <noreply@sijalneupane.tech>'
    # ONLY send HTML version - no plain text to avoid duplicate emails
    SendEmailJob.perform_later(to, subject, nil, html_body, from)
  end

  # ===== WELCOME EMAIL =====
  def self.welcome_email(user)
    to = user.email
    subject = "Welcome to Pet Haven Hub, #{user.name}! 🐾"
    first_name = user.name&.split&.first || user.name
    
    html_body = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f9f5f0; }
          .container { max-width: 650px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); overflow: hidden; }
          .header { background: linear-gradient(135deg, #ff9d5c 0%, #ffb380 100%); padding: 50px 30px; text-align: center; color: white; }
          .header h1 { margin: 0; font-size: 32px; font-weight: 700; letter-spacing: -0.5px; }
          .header p { margin: 8px 0 0 0; font-size: 16px; opacity: 0.95; }
          .content { padding: 50px 30px; }
          .message { font-size: 16px; color: #333333; line-height: 1.7; margin: 0 0 28px 0; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #ff9d5c 0%, #ffb380 100%); color: white; padding: 16px 48px; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 16px; margin: 32px 0; box-shadow: 0 4px 12px rgba(255, 157, 92, 0.3); text-align: center; }
          .footer { background-color: #f9f5f0; padding: 30px; text-align: center; border-top: 1px solid #eeeeee; }
          .footer-text { color: #888888; font-size: 13px; margin: 8px 0; }
          .footer-link { color: #ff9d5c; text-decoration: none; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🐾 Pet Haven Hub</h1>
            <p>Welcome to Your Pet Adoption Platform</p>
          </div>

          <div class="content">
            <h2 style="color: #ff9d5c; font-size: 28px; margin: 0 0 20px 0; font-weight: 700;">
              Welcome to Pet Haven Hub, #{first_name}! 🐾
            </h2>

            <p class="message">
              We're thrilled to have you join our pet-loving community! 🎉
            </p>

            <p class="message">
              Pet Haven Hub is your trusted platform to find your perfect furry (or feathered!) companion. Whether you're looking for a playful dog, a cuddly cat, a hoppy rabbit, or any other amazing pet, we're here to help you discover your new best friend.
            </p>

            <p class="message">
              Browse through hundreds of adorable pets available for adoption, learn about their personalities and needs, and take the first step toward giving a deserving animal a loving home. 🏡💕
            </p>

            <div style="text-align: center;">
              <a href="https://sijalneupane.tech/pets" class="cta-button">Browse Pets →</a>
            </div>

            <p class="message">
              If you have any questions or run into issues, our support team is here to help. Just reply to this email or visit our FAQ.
            </p>

            <p class="message">
              Happy pet hunting! 🐶🐱🐰
            </p>
          </div>

          <div class="footer">
            <p class="footer-text"><strong>© Pet Haven Hub</strong></p>
            <p class="footer-text">
              <a href="mailto:noreply@sijalneupane.tech" class="footer-link">noreply@sijalneupane.tech</a>
            </p>
            <p class="footer-text">Your Pet Adoption Platform</p>
          </div>
        </div>
      </body>
      </html>
    HTML

    from = 'Pet Haven Hub <noreply@sijalneupane.tech>'
    # ONLY send HTML version
    SendEmailJob.perform_later(to, subject, nil, html_body, from)
  end


  def self.adoption_request_notification(adoption_request)
    admin_emails = User.where(role: 'admin').pluck(:email)
    return if admin_emails.blank?
    
    admin_emails.each do |admin_email|
      send_adoption_request_email(adoption_request, admin_email)
    end
  end

  private

  def self.send_adoption_request_email(adoption_request, admin_email)
    to = admin_email
    subject = "🐾 New Adoption Request Received!"
    user = adoption_request.user
    pet = adoption_request.pet
    
    html_body = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f9f5f0; }
          .container { max-width: 650px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); overflow: hidden; }
          .header { background: linear-gradient(135deg, #5b4e8c 0%, #7c6fa8 100%); padding: 50px 30px; text-align: center; color: white; }
          .header h1 { margin: 0; font-size: 32px; font-weight: 700; }
          .header p { margin: 8px 0 0 0; font-size: 16px; opacity: 0.95; }
          .content { padding: 50px 30px; }
          .message { font-size: 16px; color: #333333; line-height: 1.7; margin: 0 0 28px 0; }
          table { width: 100%; border-collapse: collapse; margin: 28px 0; background-color: #f9f5f0; border-radius: 8px; overflow: hidden; }
          tr { border-bottom: 1px solid #e8e3d9; }
          tr:last-child { border-bottom: none; }
          td { padding: 16px; font-size: 15px; }
          td:first-child { background-color: #f0ede7; color: #666666; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; width: 35%; }
          td:last-child { color: #333333; }
          .cta-button { display: inline-block; background: linear-gradient(135deg, #5b4e8c 0%, #7c6fa8 100%); color: white; padding: 16px 48px; text-decoration: none; border-radius: 8px; font-weight: 700; font-size: 16px; margin: 32px 0; box-shadow: 0 4px 12px rgba(91, 78, 140, 0.3); text-align: center; }
          .footer { background-color: #f9f5f0; padding: 30px; text-align: center; border-top: 1px solid #eeeeee; }
          .footer-text { color: #888888; font-size: 13px; margin: 8px 0; }
          .footer-link { color: #5b4e8c; text-decoration: none; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🐾 New Adoption Request</h1>
            <p>Pet Haven Hub Admin Dashboard</p>
          </div>

          <div class="content">
            <p class="message">
              A new adoption request has been submitted and is waiting for your review.
            </p>

            <table>
              <tr>
                <td>Requester Name</td>
                <td>#{user.name}</td>
              </tr>
              <tr>
                <td>Email</td>
                <td><a href="mailto:#{user.email}" style="color: #5b4e8c; text-decoration: none;">#{user.email}</a></td>
              </tr>
              <tr>
                <td>Pet Name</td>
                <td><strong>#{pet.name}</strong></td>
              </tr>
              <tr>
                <td>Pet Breed</td>
                <td>#{pet.breed || 'Not specified'}</td>
              </tr>
              <tr>
                <td>Pet Age</td>
                <td>#{pet.age} #{pet.age == 1 ? 'year' : 'years'} old</td>
              </tr>
              <tr>
                <td>Request Date</td>
                <td>#{adoption_request.created_at.strftime('%B %d, %Y at %I:%M %p')}</td>
              </tr>
            </table>

            <p class="message">
              This is an automated notification. Please review the request and take appropriate action.
            </p>

            <div style="text-align: center;">
              <a href="https://sijalneupane.tech/admin/requests/#{adoption_request.id}" class="cta-button">Review Request →</a>
            </div>
          </div>

          <div class="footer">
            <p class="footer-text"><strong>© Pet Haven Hub</strong></p>
            <p class="footer-text">
              <a href="mailto:noreply@sijalneupane.tech" class="footer-link">noreply@sijalneupane.tech</a>
            </p>
            <p class="footer-text">Admin Dashboard</p>
          </div>
        </div>
      </body>
      </html>
    HTML

    from = 'Pet Haven Hub <noreply@sijalneupane.tech>'
    # ONLY send HTML version
    SendEmailJob.perform_later(to, subject, nil, html_body, from)
  end

  # ===== PRIVATE HELPER METHODS =====
  private

  def self.get_rejection_reason_text(adoption_request, reason_enum = nil)
    pet = adoption_request.pet
    reason_enum ||= adoption_request.rejection_reason_enum
    admin_message = adoption_request.admin_message

    reason_map = {
      'already_adopted' => "#{pet.name} has already been adopted by another family.",
      'unsuitable_home' => "Based on the information provided, we felt #{pet.name}'s needs might not be the best match for your home environment at this time.",
      'incomplete_profile' => "We need more information about your living situation and pet care experience to make the best decision.",
      'duplicate_request' => "We found an existing request already in our system. Please check your account for status updates.",
      'reserved_for_other' => "#{pet.name} has been reserved for another adopter.",
      'other' => "Unfortunately, we were unable to approve this request at this time."
    }

    base_text = reason_map[reason_enum] || reason_map['other']

    # Add custom admin message if provided
    if admin_message.present?
      "#{base_text}\n\nAdditional Details: #{admin_message}"
    else
      base_text
    end
  end
end
