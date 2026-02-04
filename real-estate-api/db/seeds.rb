# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create Super Admin User
puts "Creating Super Admin..."

ActsAsTenant.without_tenant do
  super_admin = User.find_or_initialize_by(email: 'admin@system.com')

  if super_admin.new_record?
    super_admin.assign_attributes(
      role: :super_admin,
      status: :active,
      password: ENV['SUPER_ADMIN_PASSWORD'] || 'ChangeMe123!',
      invitation_accepted_at: Time.current
    )
    super_admin.save!
    puts "✓ Super Admin created: #{super_admin.email}"
    puts "  Default password: #{ENV['SUPER_ADMIN_PASSWORD'] || 'ChangeMe123!'}"
    puts "  ⚠️  Please change the password immediately!"
  else
    puts "✓ Super Admin already exists: #{super_admin.email}"
  end
end
