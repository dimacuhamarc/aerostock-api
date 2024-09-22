# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# for i in 1..10
#   User.create(first_name: Faker::Internet.name, last_name: "#{SecureRandom.random_number(1_00)}",email: Faker::Internet.email, password: 'password', password_confirmation: 'password')
# end
# 

puts "Creating system user..."

User.create(first_name: 'System', last_name: 'Aerostock', email: 'system@aerostock.app', password: 'password', password_confirmation: 'password')

puts "Creating items..."

for i in 1..10
  Item.create(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.sentences(number: 1),
    product_number: Faker::Barcode.ean,
    serial_number: Faker::Barcode.ean,
    quantity: SecureRandom.random_number(1_00),
    uom: Faker::Commerce.promotion_code(),
    date_manufactured: Faker::Date.between(from: 5.years.ago, to: Date.today),
    date_expired: Faker::Date.between(from: Date.today, to: 5.years.from_now),
    location: Faker::Address.full_address,
    remarks: Faker::Lorem.sentences(number: 1),
    date_arrival_to_warehouse: Faker::Date.between(from: 1.months.ago, to: Date.today),
    authorized_inspection_personnel: Faker::Name.name
  )
end

puts "Seeding done!"
