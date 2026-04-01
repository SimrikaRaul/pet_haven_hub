require 'net/http'
require 'uri'
require 'json'

class MailgunService
  MAILGUN_API_KEY = ENV['MAILGUN_API_KEY'].to_s.strip
  MAILGUN_DOMAIN  = ENV['MAILGUN_DOMAIN'].to_s.strip
  MAILGUN_HOST    = ENV.fetch('MAILGUN_API_HOST', 'api.mailgun.net')
  DEFAULT_FROM    = ENV.fetch('MAIL_FROM_ADDRESS', 'PetHavenHub <noreply@sijalneupane.tech>')

  class << self
    def send_email(to:, subject:, text:, html: nil, from: DEFAULT_FROM)
      return credential_error unless credentials_present?

      begin
        uri = URI("https://#{MAILGUN_HOST}/v3/#{MAILGUN_DOMAIN}/messages")

        email_data = {
          'from'    => from,
          'to'      => to,
          'subject' => subject,
          'text'    => text
        }
        email_data['html'] = html if html.present?

        Rails.logger.info("📧 MailgunService: Sending to #{to}")

        http             = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl     = true
        http.read_timeout = 15
        http.open_timeout = 10

        request = Net::HTTP::Post.new(uri.request_uri)
        request.basic_auth('api', MAILGUN_API_KEY)
        request.set_form_data(email_data)

        response = http.request(request)

        Rails.logger.info("   → HTTP #{response.code}: #{response.body[0..200]}")

        if response.code == '200'
          body       = JSON.parse(response.body) rescue {}
          message_id = body['id'] || 'unknown'
          Rails.logger.info("✅ Email sent! ID: #{message_id}")
          { success: true, message_id: message_id, http_code: 200 }
        else
          Rails.logger.error("❌ Mailgun error HTTP #{response.code}: #{response.body}")
          { success: false, error: "HTTP #{response.code}: #{response.body[0..300]}", http_code: response.code.to_i }
        end

      rescue Net::OpenTimeout, Net::ReadTimeout => e
        Rails.logger.error("❌ Mailgun TIMEOUT: #{e.message}")
        { success: false, error: "Timeout: #{e.message}", http_code: nil }
      rescue StandardError => e
        Rails.logger.error("❌ Mailgun exception: #{e.class} - #{e.message}")
        { success: false, error: "#{e.class}: #{e.message}", http_code: nil }
      end
    end

    def check_credentials
      puts "=" * 50
      puts "MAILGUN_API_KEY : #{MAILGUN_API_KEY.present? ? "✅ #{MAILGUN_API_KEY[0..9]}..." : "❌ MISSING"}"
      puts "MAILGUN_DOMAIN  : #{MAILGUN_DOMAIN.present? ? "✅ #{MAILGUN_DOMAIN}" : "❌ MISSING"}"
      puts "MAILGUN_HOST    : ✅ #{MAILGUN_HOST}"
      puts "DEFAULT_FROM    : ✅ #{DEFAULT_FROM}"
      puts "=" * 50
    end

    private

    def credentials_present?
      MAILGUN_API_KEY.present? && MAILGUN_DOMAIN.present?
    end

    def credential_error
      msg = MAILGUN_API_KEY.blank? ? "MAILGUN_API_KEY missing" : "MAILGUN_DOMAIN missing"
      Rails.logger.error("❌ MailgunService: #{msg}")
      { success: false, error: msg, http_code: nil }
    end
  end
end