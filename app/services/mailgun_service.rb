# app/services/mailgun_service.rb
# =====================================================================
# MAILGUN API SERVICE - SIMPLIFIED & DEBUGGABLE
# =====================================================================
# Direct HTTP API calls to Mailgun for email delivery
# No ActionMailer, no templates - just simple email sending
#
# Usage:
#   result = MailgunService.send_email(
#     to: 'user@example.com',
#     subject: 'Welcome!',
#     text: 'Plain text content'
#   )
# =====================================================================

require 'net/http'
require 'uri'

class MailgunService
  # ✅ Configuration from environment variables
  MAILGUN_API_KEY = ENV['MAILGUN_API_KEY'].to_s.strip
  MAILGUN_DOMAIN = ENV['MAILGUN_DOMAIN'].to_s.strip
  DEFAULT_FROM = ENV.fetch('MAIL_FROM_ADDRESS', 'PetHavenHub <noreply@pethavenhub.com>')

  class << self
    # =====================================================================
    # Main method: send_email
    # =====================================================================
    # Sends email via Mailgun HTTP API
    #
    # Parameters:
    #   to:       String - recipient email (required)
    #   subject:  String - email subject (required)
    #   text:     String - plain text body (required)
    #   html:     String - HTML body (optional, overrides text in client)
    #   from:     String - sender email (optional)
    #
    # Returns:
    #   {
    #     success: true,
    #     message_id: 'abc@xyz.mailgun.org',
    #     http_code: 200
    #   }
    #   OR
    #   {
    #     success: false,
    #     error: 'Error message',
    #     http_code: 400,
    #     response_body: '...'
    #   }
    # =====================================================================
    def send_email(to:, subject:, text:, html: nil, from: DEFAULT_FROM)
      # ✅ Step 1: Validate required parameters
      if to.blank? || subject.blank? || text.blank?
        error_msg = "Missing required params: to=#{to.present?}, subject=#{subject.present?}, text=#{text.present?}"
        Rails.logger.error("❌ MailgunService.send_email: #{error_msg}")
        return {
          success: false,
          error: error_msg,
          http_code: nil
        }
      end

      # ✅ Step 2: Validate API credentials
      if MAILGUN_API_KEY.blank?
        error_msg = "MAILGUN_API_KEY not set in environment variables"
        Rails.logger.error("❌ MailgunService: #{error_msg}")
        return {
          success: false,
          error: error_msg,
          http_code: nil
        }
      end

      if MAILGUN_DOMAIN.blank?
        error_msg = "MAILGUN_DOMAIN not set in environment variables"
        Rails.logger.error("❌ MailgunService: #{error_msg}")
        return {
          success: false,
          error: error_msg,
          http_code: nil
        }
      end

      # ✅ Step 3: Build request
      begin
        api_url = "https://api.mailgun.net/v3/#{MAILGUN_DOMAIN}/messages"
        uri = URI(api_url)

        # Build form data
        email_data = {
          'from'    => from,
          'to'      => to,
          'subject' => subject,
          'text'    => text
        }
        email_data['html'] = html if html.present?

        # ✅ Step 4: Make HTTP request
        Rails.logger.info("📧 MailgunService.send_email: Sending to #{to}")
        Rails.logger.debug("   Subject: #{subject}")
        Rails.logger.debug("   API Domain: #{MAILGUN_DOMAIN}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 10
        http.open_timeout = 10

        request = Net::HTTP::Post.new(uri.request_uri)
        request.basic_auth('api', MAILGUN_API_KEY)
        request.set_form_data(email_data)

        response = http.request(request)

        # ✅ Step 5: Parse response
        Rails.logger.debug("   HTTP Code: #{response.code}")
        Rails.logger.debug("   Response: #{response.body[0..200]}")

        if response.code == '200'
          # Success - parse message ID
          require 'json'
          body = JSON.parse(response.body) rescue {}
          message_id = body['id'] || 'unknown'

          Rails.logger.info("✅ Email sent to #{to} (ID: #{message_id})")
          return {
            success: true,
            message_id: message_id,
            http_code: 200
          }
        else
          # API error
          error_msg = "HTTP #{response.code}: #{response.body[0..300]}"
          Rails.logger.error("❌ Mailgun API error: #{error_msg}")
          return {
            success: false,
            error: error_msg,
            http_code: response.code.to_i,
            response_body: response.body[0..500]
          }
        end

      rescue StandardError => e
        error_msg = "#{e.class}: #{e.message}"
        Rails.logger.error("❌ MailgunService exception: #{error_msg}")
        Rails.logger.error("   Backtrace: #{e.backtrace[0..5].join("\n   ")}")
        return {
          success: false,
          error: error_msg,
          http_code: nil,
          exception_class: e.class.name
        }
      end
    end

    
    def self.check_credentials
      Rails.logger.info("=" * 60)
      Rails.logger.info("🔍 MAILGUN SERVICE - CREDENTIAL CHECK")
      Rails.logger.info("=" * 60)
      Rails.logger.info("✅ API Key present: #{MAILGUN_API_KEY.present?}")
      Rails.logger.info("   First 10 chars: #{MAILGUN_API_KEY[0..9]}..." if MAILGUN_API_KEY.present?)
      Rails.logger.info("✅ Domain present: #{MAILGUN_DOMAIN.present?}")
      Rails.logger.info("   Domain: #{MAILGUN_DOMAIN}")
      Rails.logger.info("✅ From address: #{DEFAULT_FROM}")
      Rails.logger.info("=" * 60)
    end
  end
end

