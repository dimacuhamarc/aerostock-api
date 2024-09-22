namespace :backfill do
  desc 'Backfill audit logs for existing items'
  task audit_logs: :environment do
    Item.find_each do |item|
      # Trigger the audit log creation
      item.touch # This updates the updated_at timestamp, creating a version

      # set the whodunnit to id 1 to indicate that the audit log was created by the system
      # as integer 1 is the id of the system user
      PaperTrail.request.whodunnit = User.first.id

      # Save the item to persist the audit log
      item.save! # Save the item
    end
    
    puts 'Audit logs backfilled for all items.'
  end
end
