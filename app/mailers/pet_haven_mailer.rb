class PetHavenMailer
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
      </head>
      <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f9f5f0;">
        <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1) overflow: hidden;">
          <!-- Header -->
          <div style="background: linear-gradient(135deg, #ff9d5c 0%, #ffb380 100%); padding: 40px 20px; text-align: center;">
            <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 700; letter-spacing: -0.5px;">
              🐾 Pet Haven Hub
            </h1>
            <p style="color: rgba(255, 255, 255, 0.9); margin: 8px 0 0 0; font-size: 14px;">Your Pet Adoption Platform</p>
          </div>

          <!-- Content -->
          <div style="padding: 40px 30px;">
            <h2 style="color: #ff9d5c; font-size: 24px; margin: 0 0 16px 0; font-weight: 700;">
              Welcome to Pet Haven Hub, #{first_name}! 🐾
            </h2>

            <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 16px 0;">
              We're thrilled to have you join our pet-loving community! 🎉
            </p>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 0 0 20px 0;">
              Pet Haven Hub is your trusted platform to find your perfect furry (or feathered!) companion. Whether you're looking for a playful dog, a cuddly cat, a hoppy rabbit, or any other amazing pet, we're here to help you discover your new best friend.
            </p>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 0 0 28px 0;">
              Browse through hundreds of adorable pets available for adoption, learn about their personalities and needs, and take the first step toward giving a deserving animal a loving home. 🏡💕
            </p>

            <!-- CTA Button -->
            <div style="text-align: center; margin: 32px 0;">
              <a href="https://sijalneupane.tech/pets" style="display: inline-block; background: linear-gradient(135deg, #ff9d5c 0%, #ffb380 100%); color: #ffffff; padding: 14px 40px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 16px; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 12px rgba(255, 157, 92, 0.3);">
                Browse Pets →
              </a>
            </div>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 28px 0 0 0;">
              If you have any questions or run into issues, our support team is here to help. Just reply to this email or visit our FAQ.
            </p>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 16px 0 0 0;">
              Happy pet hunting! 🐶🐱🐰
            </p>
          </div>

          <!-- Footer -->
          <div style="background-color: #f9f5f0; padding: 24px 30px; text-align: center; border-top: 1px solid #eeeeee;">
            <p style="color: #888888; font-size: 13px; margin: 0 0 8px 0;">
              <strong>© Pet Haven Hub</strong>
            </p>
            <p style="color: #999999; font-size: 12px; margin: 0;">
              <a href="mailto:noreply@sijalneupane.tech" style="color: #ff9d5c; text-decoration: none;">noreply@sijalneupane.tech</a>
            </p>
          </div>
        </div>
      </body>
      </html>
    HTML

    text_body = <<-TEXT
      Welcome to Pet Haven Hub, #{first_name}!
      
      We're thrilled to have you join our pet-loving community!
      
      Pet Haven Hub is your trusted platform to find your perfect furry (or feathered!) companion. Whether you're looking for a playful dog, a cuddly cat, a hoppy rabbit, or any other amazing pet, we're here to help you discover your new best friend.
      
      Browse through hundreds of adorable pets available for adoption, learn about their personalities and needs, and take the first step toward giving a deserving animal a loving home.
      
      You can start browsing pets here: https://sijalneupane.tech/pets
      
      If you have any questions or run into issues, our support team is here to help.
      
      Happy pet hunting!
      
      © Pet Haven Hub
      noreply@sijalneupane.tech
    TEXT

    from = 'PetHavenHub <noreply@sijalneupane.tech>'
    SendEmailJob.perform_later(to, subject, text_body, html_body, from)
  end

  def self.adoption_request_notification(adoption_request)
    to = ENV['ADMIN_EMAIL'] || 'admin@sijalneupane.tech'
    subject = "🐾 New Adoption Request Received!"
    user = adoption_request.user
    pet = adoption_request.pet
    
    html_body = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f9f5f0;">
        <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); overflow: hidden;">
          <!-- Header -->
          <div style="background: linear-gradient(135deg, #5b4e8c 0%, #7c6fa8 100%); padding: 40px 20px; text-align: center;">
            <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 700;">
              🐾 New Adoption Request
            </h1>
            <p style="color: rgba(255, 255, 255, 0.9); margin: 8px 0 0 0; font-size: 14px;">Pet Haven Hub Admin</p>
          </div>

          <!-- Content -->
          <div style="padding: 40px 30px;">
            <p style="color: #333333; font-size: 15px; line-height: 1.6; margin: 0 0 24px 0;">
              A new adoption request has been submitted and is waiting for your review.
            </p>

            <!-- Request Details Table -->
            <table style="width: 100%; border-collapse: collapse; margin: 24px 0; background-color: #f9f5f0; border-radius: 6px; overflow: hidden;">
              <tr style="border-bottom: 1px solid #e8e3d9;">
                <td style="padding: 14px 16px; background-color: #f0ede7; color: #666666; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Requester Name</td>
                <td style="padding: 14px 16px; color: #333333; font-size: 15px;">#{user.name}</td>
              </tr>
              <tr style="border-bottom: 1px solid #e8e3d9;">
                <td style="padding: 14px 16px; background-color: #f0ede7; color: #666666; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Email</td>
                <td style="padding: 14px 16px; color: #333333; font-size: 15px;">
                  <a href="mailto:#{user.email}" style="color: #5b4e8c; text-decoration: none;">#{user.email}</a>
                </td>
              </tr>
              <tr style="border-bottom: 1px solid #e8e3d9;">
                <td style="padding: 14px 16px; background-color: #f0ede7; color: #666666; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Pet Name</td>
                <td style="padding: 14px 16px; color: #333333; font-size: 15px;"><strong>#{pet.name}</strong></td>
              </tr>
              <tr style="border-bottom: 1px solid #e8e3d9;">
                <td style="padding: 14px 16px; background-color: #f0ede7; color: #666666; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Pet Breed</td>
                <td style="padding: 14px 16px; color: #333333; font-size: 15px;">#{pet.breed || 'Not specified'}</td>
              </tr>
              <tr style="border-bottom: 1px solid #e8e3d9;">
                <td style="padding: 14px 16px; background-color: #f0ede7; color: #666666; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Pet Age</td>
                <td style="padding: 14px 16px; color: #333333; font-size: 15px;">#{pet.age} #{pet.age == 1 ? 'year' : 'years'} old</td>
              </tr>
              <tr>
                <td style="padding: 14px 16px; background-color: #f0ede7; color: #666666; font-weight: 600; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px;">Request Date</td>
                <td style="padding: 14px 16px; color: #333333; font-size: 15px;">#{adoption_request.created_at.strftime('%B %d, %Y at %I:%M %p')}</td>
              </tr>
            </table>

            <!-- CTA Button -->
            <div style="text-align: center; margin: 32px 0;">
              <a href="https://sijalneupane.tech/admin/requests/#{adoption_request.id}" style="display: inline-block; background: linear-gradient(135deg, #5b4e8c 0%, #7c6fa8 100%); color: #ffffff; padding: 14px 40px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 16px; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 12px rgba(91, 78, 140, 0.3);">
                Review Request →
              </a>
            </div>

            <p style="color: #888888; font-size: 13px; line-height: 1.6; margin: 24px 0 0 0; border-top: 1px solid #e8e3d9; padding-top: 16px;">
              This is an automated notification. Please review the request and take appropriate action.
            </p>
          </div>

          <!-- Footer -->
          <div style="background-color: #f9f5f0; padding: 24px 30px; text-align: center; border-top: 1px solid #eeeeee;">
            <p style="color: #888888; font-size: 13px; margin: 0 0 8px 0;">
              <strong>© Pet Haven Hub</strong>
            </p>
            <p style="color: #999999; font-size: 12px; margin: 0;">
              <a href="mailto:noreply@sijalneupane.tech" style="color: #5b4e8c; text-decoration: none;">noreply@sijalneupane.tech</a>
            </p>
          </div>
        </div>
      </body>
      </html>
    HTML

    text_body = <<-TEXT
      New Adoption Request Received!
      
      A new adoption request has been submitted and is waiting for your review.
      
      --- REQUEST DETAILS ---
      
      Requester Name: #{user.name}
      Email: #{user.email}
      Pet Name: #{pet.name}
      Pet Breed: #{pet.breed || 'Not specified'}
      Pet Age: #{pet.age} #{pet.age == 1 ? 'year' : 'years'} old
      Request Date: #{adoption_request.created_at.strftime('%B %d, %Y at %I:%M %p')}
      
      Review this request here:
      https://sijalneupane.tech/admin/requests/#{adoption_request.id}
      
      --- END DETAILS ---
      
      © Pet Haven Hub
      noreply@sijalneupane.tech
    TEXT

    from = 'PetHavenHub <noreply@sijalneupane.tech>'
    SendEmailJob.perform_later(to, subject, text_body, html_body, from)
  end

  def self.adoption_approved_email(adoption_request)
    to = adoption_request.user.email
    subject = "🎉 Congratulations! Your Adoption is Approved! 🐾"
    pet = adoption_request.pet
    user = adoption_request.user
    
    html_body = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f9f5f0;">
        <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); overflow: hidden;">
          <!-- Header -->
          <div style="background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%); padding: 40px 20px; text-align: center;">
            <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 700;">
              🎉 Congratulations!
            </h1>
            <p style="color: rgba(255, 255, 255, 0.9); margin: 8px 0 0 0; font-size: 14px;">Your Adoption is Approved</p>
          </div>

          <!-- Content -->
          <div style="padding: 40px 30px;">
            <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
              <strong>#{user.name},</strong>
            </p>

            <p style="color: #27ae60; font-size: 18px; line-height: 1.6; margin: 0 0 24px 0; font-weight: 600;">
              Your adoption request for <strong>#{pet.name}</strong> has been approved! 🐾
            </p>

            <div style="background-color: #f0fdf4; border-left: 4px solid #27ae60; padding: 20px; border-radius: 4px; margin: 24px 0;">
              <h3 style="color: #27ae60; margin: 0 0 12px 0; font-size: 16px;">Next Steps:</h3>
              <ul style="color: #333333; font-size: 15px; line-height: 1.8; margin: 0; padding-left: 20px;">
                <li>We will contact you shortly with detailed instructions on completing the adoption process</li>
                <li>Schedule a time to pick up #{pet.name} from the shelter</li>
                <li>Bring valid identification and any required documents</li>
                <li>Complete final paperwork and welcome your new family member home!</li>
              </ul>
            </div>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 24px 0;">
              We're so excited for you and #{pet.name}! This is the beginning of an amazing friendship. 💕
            </p>

            <!-- CTA Button -->
            <div style="text-align: center; margin: 32px 0;">
              <a href="https://sijalneupane.tech/requests/#{adoption_request.id}" style="display: inline-block; background: linear-gradient(135deg, #27ae60 0%, #2ecc71 100%); color: #ffffff; padding: 14px 40px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 16px; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);">
                View Your Adoption →
              </a>
            </div>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 28px 0 0 0;">
              Questions? We're always here to help. Don't hesitate to reach out!
            </p>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 16px 0 0 0;">
              Thank you for choosing adoption and giving a loving home to a deserving pet. 🏡
            </p>
          </div>

          <!-- Footer -->
          <div style="background-color: #f9f5f0; padding: 24px 30px; text-align: center; border-top: 1px solid #eeeeee;">
            <p style="color: #888888; font-size: 13px; margin: 0 0 8px 0;">
              <strong>© Pet Haven Hub</strong>
            </p>
            <p style="color: #999999; font-size: 12px; margin: 0;">
              <a href="mailto:noreply@sijalneupane.tech" style="color: #27ae60; text-decoration: none;">noreply@sijalneupane.tech</a>
            </p>
          </div>
        </div>
      </body>
      </html>
    HTML

    text_body = <<-TEXT
      Congratulations! Your Adoption is Approved! 🎉🐾
      
      #{user.name},
      
      Your adoption request for #{pet.name} has been approved!
      
      NEXT STEPS:
      
      • We will contact you shortly with detailed instructions on completing the adoption process
      • Schedule a time to pick up #{pet.name} from the shelter
      • Bring valid identification and any required documents
      • Complete final paperwork and welcome your new family member home!
      
      We're so excited for you and #{pet.name}! This is the beginning of an amazing friendship.
      
      You can view your adoption details here:
      https://sijalneupane.tech/requests/#{adoption_request.id}
      
      Questions? We're always here to help. Don't hesitate to reach out!
      
      Thank you for choosing adoption and giving a loving home to a deserving pet.
      
      © Pet Haven Hub
      noreply@sijalneupane.tech
    TEXT

    from = 'PetHavenHub <noreply@sijalneupane.tech>'
    SendEmailJob.perform_later(to, subject, text_body, html_body, from)
  end

  def self.adoption_rejected_email(adoption_request)
    to = adoption_request.user.email
    subject = "Update on Your Adoption Request for #{adoption_request.pet.name}"
    pet = adoption_request.pet
    user = adoption_request.user
    
    html_body = <<-HTML
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background-color: #f9f5f0;">
        <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); overflow: hidden;">
          <!-- Header -->
          <div style="background: linear-gradient(135deg, #8b7355 0%, #a68368 100%); padding: 40px 20px; text-align: center;">
            <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 700;">
              Update on Your Request
            </h1>
            <p style="color: rgba(255, 255, 255, 0.9); margin: 8px 0 0 0; font-size: 14px;">Pet Haven Hub</p>
          </div>

          <!-- Content -->
          <div style="padding: 40px 30px;">
            <p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 16px 0;">
              <strong>Hello #{user.name},</strong>
            </p>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 0 0 20px 0;">
              Thank you for your interest in #{pet.name}. We appreciate the time and care you put into your adoption request.
            </p>

            <div style="background-color: #fef3e2; border-left: 4px solid #d4a574; padding: 20px; border-radius: 4px; margin: 24px 0;">
              <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 0;">
                Unfortunately, #{pet.name} may have already found their forever home with another family, or there were other circumstances that prevented us from moving forward with your request at this time.
              </p>
            </div>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 24px 0;">
              <strong>But don't be discouraged!</strong> There are many wonderful pets waiting to meet you. Each pet is unique, and we're confident you'll find the perfect match for your home and lifestyle.
            </p>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 24px 0;">
              We encourage you to browse our available pets and submit another adoption request. Our team would love to help you find your new best friend. 🐾
            </p>

            <!-- CTA Button -->
            <div style="text-align: center; margin: 32px 0;">
              <a href="https://sijalneupane.tech/pets" style="display: inline-block; background: linear-gradient(135deg, #8b7355 0%, #a68368 100%); color: #ffffff; padding: 14px 40px; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 16px; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 12px rgba(139, 115, 85, 0.3);">
                Browse Other Pets →
              </a>
            </div>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 28px 0 0 0;">
              If you'd like more information about this decision or if you have questions, please don't hesitate to reach out to our support team.
            </p>

            <p style="color: #555555; font-size: 15px; line-height: 1.7; margin: 16px 0 0 0;">
              We're here to support you on your adoption journey. 💕
            </p>
          </div>

          <!-- Footer -->
          <div style="background-color: #f9f5f0; padding: 24px 30px; text-align: center; border-top: 1px solid #eeeeee;">
            <p style="color: #888888; font-size: 13px; margin: 0 0 8px 0;">
              <strong>© Pet Haven Hub</strong>
            </p>
            <p style="color: #999999; font-size: 12px; margin: 0;">
              <a href="mailto:noreply@sijalneupane.tech" style="color: #8b7355; text-decoration: none;">noreply@sijalneupane.tech</a>
            </p>
          </div>
        </div>
      </body>
      </html>
    HTML

    text_body = <<-TEXT
      Update on Your Adoption Request for #{pet.name}
      
      Hello #{user.name},
      
      Thank you for your interest in #{pet.name}. We appreciate the time and care you put into your adoption request.
      
      Unfortunately, #{pet.name} may have already found their forever home with another family, or there were other circumstances that prevented us from moving forward with your request at this time.
      
      But don't be discouraged! There are many wonderful pets waiting to meet you. Each pet is unique, and we're confident you'll find the perfect match for your home and lifestyle.
      
      We encourage you to browse our available pets and submit another adoption request. You can explore all available pets here:
      https://sijalneupane.tech/pets
      
      Our team would love to help you find your new best friend!
      
      If you'd like more information about this decision or if you have questions, please don't hesitate to reach out to our support team.
      
      We're here to support you on your adoption journey.
      
      © Pet Haven Hub
      noreply@sijalneupane.tech
    TEXT

    from = 'PetHavenHub <noreply@sijalneupane.tech>'
    SendEmailJob.perform_later(to, subject, text_body, html_body, from)
  end
end
