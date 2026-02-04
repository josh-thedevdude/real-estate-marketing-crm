# Configure acts_as_tenant for multi-tenancy support
ActsAsTenant.configure do |config|
  # Require tenant to be set for all queries (except for models with optional: true)
  config.require_tenant = true
  
  # Use :id as the primary key
  config.pkey = :id
end

