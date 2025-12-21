# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# ============================================================================
# ACADEMIC DEMONSTRATION - DUMMY DATA
# ============================================================================
# This seed file uses dummy data with Nepal-based locations for academic 
# demonstration purposes only. Pet images use placeholder URLs from:
# - https://placedog.net for dogs
# - https://placekitten.com for cats
#
# Note: The admin upload feature remains unchanged for real data entry.
# ============================================================================

require 'csv'

puts "🐾 Starting to seed pets data from CSV..."
puts "📝 Note: Using dummy data with placeholder images for academic demonstration"
puts ""

# Path to the CSV file
csv_file_path = Rails.root.join('db', 'pets_dataset.csv')

# Check if the CSV file exists
unless File.exist?(csv_file_path)
  puts "❌ CSV file not found at #{csv_file_path}"
  exit
end

# Counter for tracking records
total_records = 0
created_records = 0
skipped_records = 0

# Read and process the CSV file
CSV.foreach(csv_file_path, headers: true, header_converters: :symbol) do |row|
  total_records += 1
  
  # Convert string boolean values to actual booleans
  vaccinated = row[:vaccinated].to_s.downcase == 'true'
  affectionate = row[:affectionate].to_s.downcase == 'true'
  apartment_friendly = row[:apartment_friendly].to_s.downcase == 'true'
  kids_friendly = row[:kids_friendly].to_s.downcase == 'true'
  social_with_children = row[:social_with_children].to_s.downcase == 'true'
  social_with_other_pets = row[:social_with_other_pets].to_s.downcase == 'true'
  available = row[:available].to_s.downcase == 'true'
  
  # Check if pet already exists (based on name, breed, and age to avoid exact duplicates)
  existing_pet = Pet.find_by(
    name: row[:name],
    breed: row[:breed],
    age: row[:age].to_i
  )
  
  if existing_pet
    skipped_records += 1
    puts "⏭️  Skipping duplicate: #{row[:name]} (#{row[:breed]})"
    next
  end
  
  # Create new pet record
  begin
    pet = Pet.create!(
      name: row[:name],
      pet_type: row[:pet_type],
      breed: row[:breed],
      age: row[:age].to_i,
      sex: row[:sex],
      size: row[:size],
      location: row[:location],
      city: row[:city],
      country: row[:country],
      description: row[:description],
      health_status: row[:health_status],
      vaccinated: vaccinated,
      energy_level: row[:energy_level],
      temperament: row[:temperament],
      affectionate: affectionate,
      apartment_friendly: apartment_friendly,
      kids_friendly: kids_friendly,
      social_with_children: social_with_children,
      social_with_other_pets: social_with_other_pets,
      trainability: row[:trainability],
      grooming_needs: row[:grooming_needs],
      exercise_needs: row[:exercise_needs],
      status: row[:status],
      available: available,
      user_id: nil  # No owner initially - these are shelter pets
    )
    # Note: Image field intentionally left empty for dummy data
    # Admin upload feature remains available for real pet entries
    
    created_records += 1
    puts "✅ Created: #{pet.name} (#{pet.pet_type} - #{pet.breed})"
  rescue ActiveRecord::RecordInvalid => e
    skipped_records += 1
    puts "❌ Failed to create #{row[:name]}: #{e.message}"
  end
end

puts "\n" + "="*60
puts "🎉 Seeding completed!"
puts "="*60
puts "📊 Summary:"
puts "   Total records in CSV: #{total_records}"
puts "   Successfully created: #{created_records}"
puts "   Skipped/Failed: #{skipped_records}"
puts "="*60
puts "✨ Database now has #{Pet.count} total pets"
puts "="*60
