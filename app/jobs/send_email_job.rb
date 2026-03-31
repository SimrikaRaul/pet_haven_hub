

class SendEmailJob < ApplicationJob
  queue_as :mailers
  
  # Automatically retry on any error (max 5 times)
  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  
  # Discard job if it fails after retries (optional)
  discard_on ActiveJob::DeserializationError

 
  def perform(to, subject, text, html = nil, from = nil)
    job_id = jid
    attempt = executions
    
    Rails.logger.info("=" * 70)
    Rails.logger.info("📧 SendEmailJob [#{job_id}] - Attempt #{attempt}/5")
    Rails.logger.info("   To: #{to}")
    Rails.logger.info("   Subject: #{subject[0..50]}#{'...' if subject.length > 50}")
    Rails.logger.info("=" * 70)

    # Build email parameters
    email_params = {
      to: to,
      subject: subject,
      text: text
    }
    email_params[:html] = html if html.present?
    email_params[:from] = from if from.present?

    # Send email via MailgunService
    result = MailgunService.send_email(**email_params)

    # Handle result
    if result[:success]
      Rails.logger.info("✅ EMAIL SENT")
      Rails.logger.info("   Job ID: #{job_id}")
      Rails.logger.info("   Message ID: #{result[:message_id]}")
      Rails.logger.info("   HTTP Code: #{result[:http_code]}")
      Rails.logger.info("=" * 70)
      return true
    else
      # Log failure details for debugging
      Rails.logger.error("❌ EMAIL FAILED")
      Rails.logger.error("   Job ID: #{job_id}")
      Rails.logger.error("   Attempt: #{attempt}/5")
      Rails.logger.error("   To: #{to}")
      Rails.logger.error("   Error: #{result[:error]}")
      Rails.logger.error("   HTTP Code: #{result[:http_code]}")
      if result[:response_body]
        Rails.logger.error("   Response: #{result[:response_body]}")
      end
      Rails.logger.error("=" * 70)
      
      # Re-raise to trigger automatic retry
      raise "MailgunService returned failure: #{result[:error]}"
    end
  end

 
  def on_discard(error)
    Rails.logger.fatal("💥 SendEmailJob PERMANENTLY FAILED after all retries")
    Rails.logger.fatal("   Job ID: #{jid}")
    Rails.logger.fatal("   Error: #{error.message}")
    Rails.logger.fatal("   Arguments: to=#{arguments[0]}, subject=#{arguments[1][0..50]}")
  end
end
