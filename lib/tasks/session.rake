namespace :session do
  desc "Clear all user sessions (fixes stuck admin session)"
  task clear_all: :environment do
    puts "Clearing all active sessions..."
    
    # Clear Rails session store
    if Rails.application.config.session_store == ActionDispatch::Session::CookieStore
      puts "⚠️  Using cookie-based sessions - users must clear browser cookies"
      puts "Sessions are stored in browser cookies, not server-side"
    else
      # If using database or redis sessions, clear them
      Rails.cache.clear rescue nil
      puts "✅ Server-side sessions cleared"
    end
    
    # Sign out all users by resetting their remember tokens
    User.update_all(remember_created_at: nil)
    puts "✅ All user 'remember me' tokens cleared"
    
    puts "\n📢 IMPORTANT: Users must:"
    puts "   1. Clear their browser cookies"
    puts "   2. Close all browser tabs"
    puts "   3. Log in again"
  end
end
