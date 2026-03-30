
# ============================================================================
# PET ADOPTION SYSTEM - SEED DATA
# ============================================================================
# This seed file generates 100 sample pets for development and demonstration.
# It is idempotent - safe to run multiple times without creating duplicates.
# Uses ActiveStorage to attach random images from db/seeds_images folder.
# Admin manual pet creation via the admin panel remains fully functional.
# ============================================================================

puts "🐾 Starting Pet Haven Hub seeding process..."
puts "=" * 70

# ============================================================================
# ADMIN USER CREATION
# ============================================================================

puts "\n👤 Creating admin user..."
admin_user = User.find_or_create_by!(email: "raulsimrika@gmail.com") do |user|
  user.password = "PetHub#Admin27$"
  user.password_confirmation = "PetHub#Admin27$"
  user.role = "admin"
  user.name = "Admin"
end
puts "✅ Admin user created: #{admin_user.email}"

# ============================================================================
# IMAGE LOADING CONFIGURATION
# ============================================================================

# Load all images from db/seeds_images folder
seeds_images_path = Rails.root.join('db', 'seeds_images')
image_files = []

if Dir.exist?(seeds_images_path)
  image_files = Dir.glob(seeds_images_path.join('**', '*')).select do |file|
    File.file?(file) && file.match?(/\.(jpg|jpeg|png|gif|webp)$/i)
  end
  puts "📸 Found #{image_files.length} images in db/seeds_images folder"
else
  puts "⚠️  Warning: db/seeds_images folder not found. Pets will be created without images."
  puts "   Create the folder and add images if you want pets to have photos."
end

puts "=" * 70

# ============================================================================
# SEED DATA CONFIGURATION
# ============================================================================

DOG_NAMES = %w[Max Bella Luna Charlie Cooper Daisy Rocky Bailey Lucy Sadie Molly Buddy Duke Bear Oliver Sophie Jack Lola Riley Toby Maggie Chluna Bentley Coco Zeus Pepper Harley Shadow Tucker Milo Ruby Rosie Jasper]
CAT_NAMES = %w[Luna Oliver Simba Milo Bella Cleo Tigger Charlie Kitty Smokey Shadow Misty Whiskers Felix Nala Oscar Leo Ginger Mittens Pumpkin Oreo Patches Salem Socks Tiger Loki Princess Jasper Chloe]
RABBIT_NAMES = %w[Thumper Cottontail Bunny Fluffy Snowball Clover Marshmallow Peter Hoppy Nibbles Cookie Cinnamon Patches Flopsy Cotton Pepper Hazel Daisy Maple Willow Honey]
PARROT_NAMES = %w[Tweety Chirpy Kiwi Sunny Rio Blue Sky Phoenix Coco Mango Charlie Pepper Angel Buddy Lucky Pearl Ruby Sunny Sweetie Ziggy]

DOG_BREEDS = %w[Labrador Golden\ Retriever German\ Shepherd Beagle Bulldog Poodle Rottweiler Boxer Husky Dachshund Shih\ Tzu Pug Chihuahua Border\ Collie Cocker\ Spaniel Maltese Doberman Terrier Mastiff Corgi]
CAT_BREEDS = %w[Persian Siamese Maine\ Coon Ragdoll Bengal Sphynx British\ Shorthair Abyssinian Scottish\ Fold American\ Shorthair Russian\ Blue Norwegian\ Forest Birman Burmese Himalayan Exotic\ Shorthair Devon\ Rex Tabby Calico Mixed]
RABBIT_BREEDS = %w[Dutch Lionhead Mini\ Lop Holland\ Lop Flemish\ Giant Rex Angora Netherland\ Dwarf English\ Lop Polish Himalayan]
PARROT_BREEDS = %w[African\ Grey Macaw Cockatiel Conure Amazon Eclectus Cockatoo Lovebird Budgerigar Senegal]

LOCATIONS = [
  { city: "Kathmandu", country: "Nepal" },
  { city: "Pokhara", country: "Nepal" },
  { city: "Lalitpur", country: "Nepal" },
  { city: "Bhaktapur", country: "Nepal" }
]

# Description templates
DESCRIPTION_TEMPLATES = {
  dog: [
    "A friendly and energetic companion looking for a loving home.",
    "Well-behaved and house-trained. Great with families.",
    "Playful and affectionate. Loves outdoor activities and walks.",
    "Gentle and loyal. Perfect for active families.",
    "Smart and obedient. Already knows basic commands.",
    "Sweet-natured and loves to cuddle. Good with children.",
    "Active and playful. Needs regular exercise and attention.",
    "Calm and gentle. Makes a great companion for any home."
  ],
  cat: [
    "Independent yet affectionate. Loves cozy spots and gentle pets.",
    "Playful and curious. Enjoys interactive toys and playtime.",
    "Calm and gentle. Perfect lap cat for quiet homes.",
    "Social and friendly. Gets along well with other pets.",
    "Sweet and loving. Enjoys human companionship.",
    "Active and playful. Loves to explore and play.",
    "Gentle and affectionate. Purrs at the slightest attention.",
    "Easy-going and adaptable. Great for first-time cat owners."
  ],
  rabbit: [
    "Gentle and friendly. Loves to hop around and explore.",
    "Playful and social. Enjoys gentle handling and treats.",
    "Calm and docile. Perfect indoor companion.",
    "Friendly and curious. Great with gentle children.",
    "Sweet-natured and loves to be petted.",
    "Active and playful. Needs space to hop and play.",
    "Gentle soul looking for a quiet, loving home.",
    "Social and friendly. Enjoys companionship."
  ],
  parrot: [
    "Cheerful and vocal. Loves to sing and talk.",
    "Social and friendly. Enjoys interaction and playtime.",
    "Bright and colorful. Brings joy to any home.",
    "Playful and intelligent. Can learn words and tricks.",
    "Gentle and sweet-natured. Perfect feathered friend.",
    "Active and entertaining. Loves toys and mirrors.",
    "Talkative and charming. Brightens up the day with chatter.",
    "Friendly and social. Enjoys human company."
  ]
}

created_count = 0
skipped_count = 0
failed_count = 0
images_attached = 0


100.times do |i|
  
  pet_type = ['dog', 'cat', 'rabbit', 'parrot'].sample
  
 
  name = case pet_type
         when 'dog' then DOG_NAMES.sample
         when 'cat' then CAT_NAMES.sample
         when 'rabbit' then RABBIT_NAMES.sample
         when 'parrot' then PARROT_NAMES.sample
         end
  
  breed = case pet_type
          when 'dog' then DOG_BREEDS.sample
          when 'cat' then CAT_BREEDS.sample
          when 'rabbit' then RABBIT_BREEDS.sample
          when 'parrot' then PARROT_BREEDS.sample
          end
  

  age = rand(1..8)
  sex = ['male', 'female'].sample
  
 
  size = case pet_type
         when 'dog' then ['small', 'medium', 'large'].sample
         when 'cat' then ['small', 'medium'].sample
         when 'rabbit' then ['small', 'medium'].sample
         when 'parrot' then 'small'
         end
  

  location_data = LOCATIONS.sample
  
 
  description = DESCRIPTION_TEMPLATES[pet_type.to_sym].sample
  
 
  energy_level = ['low', 'medium', 'high'].sample
  temperament = ['friendly', 'shy', 'active', 'calm'].sample
  trainability = ['easy', 'medium', 'hard'].sample
  grooming_needs = ['low', 'medium', 'high'].sample
  exercise_needs = ['low', 'medium', 'high'].sample
  

  vaccinated = [true, false].sample
  affectionate = [true, false].sample
  apartment_friendly = [true, false].sample
  kids_friendly = [true, false].sample
  social_with_children = [true, false].sample
  social_with_other_pets = [true, false].sample
  
  
  health_status = ['Excellent', 'Good', 'Healthy', 'Vaccinated and healthy'].sample
  
 
  existing_pet = Pet.find_by(name: name, breed: breed, age: age)
  
  if existing_pet
    skipped_count += 1
    print "⏭️"
    next
  end
  

  begin
    Pet.create!(
      name: name,
      pet_type: pet_type,
      breed: breed,
      age: age,
      sex: sex,
      size: size,
      city: location_data[:city],
      country: location_data[:country],
      description: description,
      health_status: health_status,
      vaccinated: vaccinated,
      energy_level: energy_level,
      temperament: temperament,
      affectionate: affectionate,
      apartment_friendly: apartment_friendly,
      kids_friendly: kids_friendly,
      social_with_children: social_with_children,
      social_with_other_pets: social_with_other_pets,
      trainability: trainability,
      grooming_needs: grooming_needs,
      exercise_needs: exercise_needs,
      status: 'available',
      available: true,
      user_id: nil  
    )
    
  
    if image_files.any?
      random_image = image_files.sample
      filename = File.basename(random_image)
      
    
      content_type = case File.extname(random_image).downcase
                     when '.jpg', '.jpeg' then 'image/jpeg'
                     when '.png' then 'image/png'
                     when '.gif' then 'image/gif'
                     when '.webp' then 'image/webp'
                     else 'image/jpeg'
                     end
      
   e
      pet.image.attach(
        io: File.open(random_image),
        filename: filename,
        content_type: content_type
      )
      
      images_attached += 1
    end
    
    created_count += 1
    print "✅"
    
  rescue ActiveRecord::RecordInvalid => e
    failed_count += 1
    print "❌"
    puts "\nFailed to create pet #{i + 1}: #{e.message}" if failed_count <= 5
  rescue StandardError => e
    failed_count += 1
    print "❌"
    puts "\nError creating pet #{i + 1}: #{e.message}" if failed_count <= 5
  end
  
 
  puts " (#{i + 1}/100)" if (i + 1) % 20 == 0
end


puts "\n" + "=" * 70
puts "🎉 Seeding Completed Successfully!"
puts "=" * 70
puts "📊 Summary:"
puts "   ✅ Successfully created: #{created_count} pets"
puts "   📸 Images attached: #{images_attached} pets"
puts "   ⏭️  Skipped (duplicates): #{skipped_count} pets"
puts "   ❌ Failed: #{failed_count} pets" if failed_count > 0
puts "=" * 70
puts "📈 Total pets in database: #{Pet.count}"
puts "=" * 70
puts "✨ Your Pet Adoption System is ready for demonstration!"
puts "💡 Admin can still manually add pets via the admin panel."
puts "=" * 70
