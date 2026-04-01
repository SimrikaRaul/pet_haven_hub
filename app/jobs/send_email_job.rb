class SendEmailJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  discard_on ActiveJob::DeserializationError

  def perform(to, subject, text, html = nil, from = nil)
    job_id  = self.job_id  # ✅ Fixed from jid
    attempt = executions

    Rails.logger.info("📧 SendEmailJob [#{job_id}] Attempt #{attempt}/5 → #{to}")

    email_params = { to: to, subject: subject, text: text }
    email_params[:html] = html if html.present?
    email_params[:from] = from if from.present?

    result = MailgunService.send_email(**email_params)

    if result[:success]
      Rails.logger.info("✅ Email sent — Message ID: #{result[:message_id]}")
    else
      Rails.logger.error("❌ Email failed (attempt #{attempt}): #{result[:error]}")
      raise "Mailgun failed: #{result[:error]}"
    end
  end
end