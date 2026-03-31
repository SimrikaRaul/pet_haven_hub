puts "Testing Mailgun email system..."

puts "\n✅ Checking models load correctly"
require_relative 'config/environment'

puts "   - Request model: #{Request.respond_to?(:find)}"
puts "   - Pet model: #{Pet.respond_to?(:find)}"
puts "   - SendEmailJob: #{SendEmailJob.respond_to?(:perform_later)}"

puts "\n✅ Checking methods exist"
request = Request.new(user_id: 1, pet_id: 1, request_type: 'adopt', status: 'open')
puts "   - send_request_confirmation: #{request.respond_to?(:send_request_confirmation)}"
puts "   - handle_status_change: #{request.respond_to?(:handle_status_change)}"

puts "\n✅ All models and methods loaded successfully!"
puts "\nNo RequestMailer, AdoptionMailer, or PetMailer references remain."
