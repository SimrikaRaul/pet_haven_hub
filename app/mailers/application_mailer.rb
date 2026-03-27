class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch('MAIL_FROM_ADDRESS', 'noreply@pethavenhub.com') }
  layout 'mailer'


  def app_name
    'Pet Haven Hub'
  end
  helper_method :app_name
end
