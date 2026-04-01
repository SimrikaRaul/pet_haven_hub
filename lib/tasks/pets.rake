namespace :pets do
  desc "Sync pet statuses with request statuses - marks pets as adopted if they have completed requests"
  task sync_statuses: :environment do
    puts "Syncing pet statuses with request statuses..."
    
    # Find all completed requests and ensure their pets are marked as adopted
    completed_count = 0
    in_process_count = 0
    
    Request.where(status: 'completed').find_each do |request|
      if request.pet.available? || request.pet.in_process?
        puts "  → Marking #{request.pet.name} as adopted (completed request ID: #{request.id})"
        request.pet.mark_as_adopted!
        completed_count += 1
      end
    end
    
    # Find all approved requests and ensure their pets are marked as in_process
    Request.where(status: 'approved').find_each do |request|
      if request.pet.available?
        puts "  → Marking #{request.pet.name} as in_process (approved request ID: #{request.id})"
        request.pet.mark_as_in_process!
        in_process_count += 1
      end
    end
    
    puts "\n✅ Sync complete!"
    puts "   - #{completed_count} pets marked as adopted"
    puts "   - #{in_process_count} pets marked as in_process"
  end

  desc "Show current pet status overview"
  task status_overview: :environment do
    puts "\n📊 Pet Status Overview:"
    puts "  Available:  #{Pet.available.count}"
    puts "  In Process: #{Pet.in_process.count}"
    puts "  Adopted:    #{Pet.adopted.count}"
    puts "  Total:      #{Pet.count}\n"
    
    puts "📚 Adopted Pets:"
    Pet.adopted.each do |pet|
      completed_request = pet.requests.where(status: 'completed').first
      adopted_date = completed_request&.completed_at&.strftime('%B %d, %Y') || 'Unknown'
      puts "  • #{pet.name} (#{pet.pet_type.titleize}) - Adopted on #{adopted_date}"
    end
  end
end
