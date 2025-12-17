namespace :recommendations do
  desc "Check if recommendation system is properly set up"
  task check: :environment do
    puts "\n🔍 Checking Pet Recommendation System Setup...\n\n"
    
    # Check 1: Database table exists
    print "✓ Checking user_preferences table... "
    if ActiveRecord::Base.connection.table_exists?('user_preferences')
      puts "✅ EXISTS"
    else
      puts "❌ MISSING - Run: rails db:migrate"
      exit 1
    end
    
    # Check 2: Model exists
    print "✓ Checking UserPreference model... "
    begin
      UserPreference
      puts "✅ LOADED"
    rescue NameError
      puts "❌ MISSING"
      exit 1
    end
    
    # Check 3: Routes exist
    print "✓ Checking routes... "
    routes_exist = Rails.application.routes.routes.any? { |r| r.name == 'recommendations' } &&
                   Rails.application.routes.routes.any? { |r| r.name == 'edit_user_preferences' }
    if routes_exist
      puts "✅ CONFIGURED"
    else
      puts "❌ MISSING"
      exit 1
    end
    
    # Check 4: Controllers exist
    print "✓ Checking controllers... "
    if File.exist?(Rails.root.join('app', 'controllers', 'user_preferences_controller.rb')) &&
       File.exist?(Rails.root.join('app', 'controllers', 'recommendations_controller.rb'))
      puts "✅ PRESENT"
    else
      puts "❌ MISSING"
      exit 1
    end
    
    # Check 5: Service exists
    print "✓ Checking PetRecommendationService... "
    begin
      PetRecommendationService
      puts "✅ LOADED"
    rescue NameError
      puts "❌ MISSING"
      exit 1
    end
    
    # Check 6: Views exist
    print "✓ Checking views... "
    if File.exist?(Rails.root.join('app', 'views', 'user_preferences', 'edit.html.erb')) &&
       File.exist?(Rails.root.join('app', 'views', 'recommendations', 'index.html.erb'))
      puts "✅ PRESENT"
    else
      puts "❌ MISSING"
      exit 1
    end
    
    # Check 7: Pets with recommendation data
    print "✓ Checking pets with recommendation data... "
    pets_with_data = Pet.where.not(energy_level: nil).count
    total_pets = Pet.count
    puts "📊 #{pets_with_data}/#{total_pets} pets have data"
    
    if pets_with_data == 0 && total_pets > 0
      puts "⚠️  WARNING: No pets have recommendation attributes set!"
      puts "   Admin should edit pets to add: energy_level, temperament, grooming_needs, exercise_needs"
    end
    
    # Summary
    puts "\n" + "="*60
    puts "✅ Recommendation System is properly configured!"
    puts "="*60
    
    puts "\n📋 Next Steps:"
    puts "1. Start server: rails s"
    puts "2. Sign in as admin"
    puts "3. Edit pets to add recommendation attributes"
    puts "4. Sign in as regular user"
    puts "5. Visit: /user_preferences/edit"
    puts "6. Fill preferences and get recommendations!"
    puts "\n"
  end
  
  desc "Show sample preference values for testing"
  task sample_data: :environment do
    puts "\n📝 Sample Preference Values for Testing:\n\n"
    
    puts "Energy Levels:"
    puts "  - low"
    puts "  - medium"
    puts "  - high\n\n"
    
    puts "Temperaments:"
    puts "  - calm"
    puts "  - friendly"
    puts "  - playful\n\n"
    
    puts "Grooming/Exercise Needs:"
    puts "  - low"
    puts "  - medium"
    puts "  - high\n\n"
    
    puts "Boolean Fields (check boxes):"
    puts "  - affectionate"
    puts "  - apartment_friendly"
    puts "  - kids_friendly"
    puts "  - social_with_other_pets"
    puts "  - social_with_children\n\n"
  end
end
