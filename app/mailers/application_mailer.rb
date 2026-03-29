class ApplicationMailer < ActionMailer::Base
  APP_NAME = 'Pet Haven Hub'.freeze
  SUPPORT_EMAIL = ENV.fetch('ADMIN_EMAIL', 'support@pethavenhub.com').freeze
 
  default from: -> { ENV.fetch('MAIL_FROM_ADDRESS', 'noreply@pethavenhub.com') }
  layout 'mailer'
end