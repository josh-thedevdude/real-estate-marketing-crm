puts "🌱 Starting seed data creation..."
puts "=" * 80

# Create Super Admin User
puts "\n📌 Creating Super Admin..."

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

# Create Test Organization and Users
puts "\n📌 Creating Test Organization..."

org = Organization.find_or_create_by!(name: 'Real Estate Pro')
puts "✓ Organization: #{org.name}"

ActsAsTenant.with_tenant(org) do
  # Create Org Admin
  puts "\n📌 Creating Organization Admin..."
  admin = User.find_or_initialize_by(email: 'orgadmin@system.com')
  if admin.new_record?
    admin.assign_attributes(
      organization: org,
      role: :org_admin,
      status: :active,
      password: 'orgadmin@12345',
      invitation_accepted_at: Time.current
    )
    admin.save!
    puts "✓ Org Admin created: #{admin.email}"
  else
    puts "✓ Org Admin already exists: #{admin.email}"
  end

  # Create Org User
  puts "\n📌 Creating Organization User..."
  user = User.find_or_initialize_by(email: 'orguser@system.com')
  if user.new_record?
    user.assign_attributes(
      organization: org,
      role: :org_user,
      status: :active,
      password: 'orguser@12345',
      invitation_accepted_at: Time.current
    )
    user.save!
    puts "✓ Org User created: #{user.email}"
  else
    puts "✓ Org User already exists: #{user.email}"
  end

  # Create Contacts
  puts "\n📌 Creating Contacts..."
  
  contacts_data = [
    {
      first_name: 'Sahil',
      last_name: 'Patil',
      email: 'sahil.patil@joshsoftware.com',
      phone: '9967060698',
      preferences: {
        contact_type: 'buyer',
        min_budget: 5000000,
        max_budget: 8000000,
        property_location: ['baner', 'hinjewadi'],
        property_type: '3bhk',
        timeline: '0-3'
      }
    },
    {
      first_name: 'Chinmay',
      last_name: 'Mahajan',
      email: 'chinmay.mahajan@joshsoftware.com',
      phone: '8264878548',
      preferences: {
        contact_type: 'buyer',
        min_budget: 8000000,
        max_budget: 12000000,
        property_location: ['hinjewadi', 'wakad'],
        property_type: '4bhk',
        timeline: '3-6'
      }
    },
    {
      first_name: 'Jagdish',
      last_name: 'Raut',
      email: 'jagdish.raut@joshsoftware.com',
      phone: '6854785987',
      preferences: {
        contact_type: 'seller',
        min_budget: 6000000,
        max_budget: 9000000,
        property_location: ['wakad'],
        property_type: '2bhk',
        timeline: '0-3'
      }
    },
    {
      first_name: 'Aman',
      last_name: 'Pathan',
      email: 'aman.pathan@joshsoftware.com',
      phone: '9685423657',
      preferences: {
        contact_type: 'buyer',
        min_budget: 4000000,
        max_budget: 6000000,
        property_location: ['kharadi', 'hadapsar'],
        property_type: '2bhk',
        timeline: '0-3'
      }
    },
  ]

  contacts_data.each do |contact_data|
    contact = Contact.find_or_initialize_by(
      email: contact_data[:email],
      organization: org
    )
    
    if contact.new_record?
      contact.assign_attributes(
        first_name: contact_data[:first_name],
        last_name: contact_data[:last_name],
        phone: contact_data[:phone],
        preferences: contact_data[:preferences],
        created_by: admin
      )
      contact.save!
      puts "✓ Contact created: #{contact.full_name} (#{contact.email})"
    else
      puts "✓ Contact already exists: #{contact.full_name}"
    end
  end

  # Create Audiences
  puts "\n📌 Creating Audiences..."

  # Audience 1: Premium Buyers (Budget > 8M)
  audience1 = Audience.find_or_initialize_by(
    name: 'Premium Buyers',
    organization: org,
    created_by: admin
  )
  
  if audience1.new_record?
    audience1.assign_attributes(
      description: 'High-budget buyers looking for premium properties',
      filters: {
        contact_type: 'buyer',
        min_budget_range: [8000000, 999999999],
        property_locations: ['wakad']
      }
    )
    audience1.save!
    puts "✓ Audience created: #{audience1.name} (#{audience1.contacts.count} contacts)"
  else
    puts "✓ Audience already exists: #{audience1.name}"
  end

  # Audience 2: Quick Buyers (Timeline: Immediately or Within 3 months)
  audience2 = Audience.find_or_initialize_by(
    name: 'Quick Buyers',
    organization: org,
    created_by: admin
  )
  
  if audience2.new_record?
    audience2.assign_attributes(
      description: 'Buyers ready to purchase within 3 months',
      filters: {
        contact_type: 'buyer',
        timelines: ['0-3']
      }
    )
    audience2.save!
    puts "✓ Audience created: #{audience2.name} (#{audience2.contacts.count} contacts)"
  else
    puts "✓ Audience already exists: #{audience2.name}"
  end

  # Audience 3: Baner & Hinjewadi Buyers
  audience3 = Audience.find_or_initialize_by(
    name: 'Baner & Hinjewadi Buyers',
    organization: org,
    created_by: admin
  )
  
  if audience3.new_record?
    audience3.assign_attributes(
      description: 'Buyers interested in Baner and Hinjewadi areas',
      filters: {
        contact_type: 'buyer',
        property_locations: ['baner', 'hinjewadi']
      }
    )
    audience3.save!
    puts "✓ Audience created: #{audience3.name} (#{audience3.contacts.count} contacts)"
  else
    puts "✓ Audience already exists: #{audience3.name}"
  end

  # Create Email Templates
  puts "\n📌 Creating Email Templates..."

  # Template 1: New Property Launch
  template1 = EmailTemplate.find_or_initialize_by(
    name: 'New Property Launch',
    organization: org,
    created_by: admin
  )
  
  if template1.new_record?
    template1.assign_attributes(
      subject: 'Exclusive: New {{property_type}} in {{location}} - Perfect for You!',
      body: <<~BODY,
        Hi {{first_name}},

        We're excited to share an exclusive new {{property_type}} available in {{location}}.

        🏠 Property Highlights:
        - Type: {{property_type}}
        - Location: {{location}}
        - Price Range: ₹{{price_range}}
        - Possession: {{possession}}

        This property matches your preferences and budget perfectly. We believe it's an excellent opportunity for you.

        📅 Schedule a viewing today!

        Best regards,
        Real Estate Pro Team

        Contact: {{phone}}
        Email: {{email}}
      BODY
      variables: {
        property_type: 'Type of property (e.g., 3BHK Apartment, Penthouse)',
        location: 'Property location (e.g., Baner, Koregaon Park)',
        price_range: 'Price range (e.g., 80L - 1.2Cr)',
        possession: 'Possession timeline (e.g., Ready to Move, Dec 2026)'
      }
    )
    template1.save!
    puts "✓ Email Template created: #{template1.name}"
  else
    puts "✓ Email Template already exists: #{template1.name}"
  end

  # Template 2: Price Drop Alert
  template2 = EmailTemplate.find_or_initialize_by(
    name: 'Price Drop Alert',
    organization: org,
    created_by: admin
  )
  
  if template2.new_record?
    template2.assign_attributes(
      subject: '🔥 Price Drop Alert: {{property_type}} in {{location}}',
      body: <<~BODY,
        Hi {{first_name}},

        Great news! The price has been reduced on a {{property_type}} in {{location}} that matches your search criteria.

        💰 Previous Price: ₹{{old_price}}
        💰 New Price: ₹{{new_price}}
        💰 You Save: ₹{{savings}}

        This is a limited-time offer and won't last long!

        Don't miss this opportunity. Contact us immediately to schedule a viewing.

        Best regards,
        Real Estate Pro Team

        Phone: {{phone}}
        Email: {{email}}
      BODY
      variables: {
        property_type: 'Type of property',
        location: 'Property location',
        old_price: 'Original price',
        new_price: 'Reduced price',
        savings: 'Amount saved'
      }
    )
    template2.save!
    puts "✓ Email Template created: #{template2.name}"
  else
    puts "✓ Email Template already exists: #{template2.name}"
  end

  puts "\n" + "=" * 80
  puts "🎉 Seed data creation completed!"
  puts "=" * 80
  
  puts "\n📊 Summary:"
  puts "  Organizations: #{Organization.count}"
  puts "  Users: #{User.count}"
  puts "  Contacts: #{Contact.count}"
  puts "  Audiences: #{Audience.count}"
  puts "  Email Templates: #{EmailTemplate.count}"
  
  puts "\n🔐 Login Credentials:"
  puts "  Org Admin: orgadmin@system.com / orgadmin@12345"
  puts "  Org User:  orguser@system.com / orguser@12345"

  puts "=" * 80
end
