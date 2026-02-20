namespace :pets do
  desc "Download sample pet images from placeholder service and attach to pets"
  task download_images: :environment do
    require 'open-uri'
    
    puts "🐾 Downloading sample pet images..."
    puts "=" * 70
    
    Pet.find_each do |pet|
      next if pet.image.attached?
      
      begin
    
        image_url = "https://picsum.photos/seed/#{pet.pet_type}_#{pet.id}/600/400"
        
        downloaded_image = URI.parse(image_url).open
        filename = "#{pet.pet_type}_#{pet.name.parameterize}_#{pet.id}.jpg"
        
        pet.image.attach(
          io: downloaded_image,
          filename: filename,
          content_type: 'image/jpeg'
        )
        
        puts "✅ Attached image to #{pet.name} (#{pet.pet_type})"
      rescue => e
        puts "❌ Failed to attach image to #{pet.name}: #{e.message}"
      end
    end
    
    puts "=" * 70
    puts "✨ Completed! #{Pet.joins(:image_attachment).count} pets now have images."
  end
  
  desc "Attach pet-specific placeholder images to pets without images"
  task attach_placeholders: :environment do
    require 'open-uri'
    
    puts "🐾 Attaching placeholder images to pets..."
    puts "=" * 70
    
    placeholders = {
      'dog' => 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=600',
      'cat' => 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=600',
      'rabbit' => 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=600',
      'bird' => 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=600'
    }
    
    Pet.find_each do |pet|
      next if pet.image.attached?
      
      begin
        placeholder_url = placeholders[pet.pet_type] || placeholders['dog']
        downloaded_image = URI.parse(placeholder_url).open
        filename = "placeholder_#{pet.pet_type}_#{pet.id}.jpg"
        
        pet.image.attach(
          io: downloaded_image,
          filename: filename,
          content_type: 'image/jpeg'
        )
        
        puts "✅ Attached placeholder to #{pet.name} (#{pet.pet_type})"
      rescue => e
        puts "❌ Failed to attach placeholder to #{pet.name}: #{e.message}"
      end
    end
    
    puts "=" * 70
    puts "✨ Completed! #{Pet.joins(:image_attachment).count} pets now have images."
  end
  
  desc "Remove all attached images from pets"
  task remove_images: :environment do
    puts "🗑️  Removing all pet images..."
    
    count = 0
    Pet.find_each do |pet|
      if pet.image.attached?
        pet.image.purge
        count += 1
      end
    end
    
    puts "✅ Removed #{count} images"
  end
end
