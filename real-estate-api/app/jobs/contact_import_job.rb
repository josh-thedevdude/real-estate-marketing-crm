require 'csv'

class ContactImportJob < ApplicationJob
  queue_as :default
  
  REQUIRED_HEADERS = %w[first_name last_name email].freeze
  PREFERENCE_COLUMNS = %w[contact_type min_budget max_budget property_locations property_types timeline].freeze
  
  # Valid enum values
  CONTACT_TYPES = %w[buyer seller renter].freeze
  PROPERTY_LOCATIONS = %w[baner wakad hinjewadi kharadi hadapsar wagholi kondhwa undri ravet moshi pimpri chinchwad akurdi].freeze
  PROPERTY_TYPES = %w[apartment villa plot commercial 1bhk 2bhk 3bhk 4bhk].freeze
  TIMELINES = %w[0-3 3-6 6-9 9-12].freeze
  
  def perform(import_log_id, file_path)
    import_log = ContactImportLog.find(import_log_id)
    import_log.update!(status: :processing)
    
    Rails.logger.info "ContactImportJob: Starting import for log #{import_log_id}, user: #{import_log.user.email}, org: #{import_log.organization.name}"
    
    errors = []
    successful = 0
    total = 0
    
    ActsAsTenant.with_tenant(import_log.organization) do
      CSV.foreach(file_path, headers: true, header_converters: :downcase) do |row|
        total += 1
        
        # Validate required headers on first row
        if total == 1 && !valid_headers?(row.headers)
          import_log.update!(
            status: :failed,
            error_details: [{
              error: "Invalid CSV headers. Required: #{REQUIRED_HEADERS.join(', ')}"
            }]
          )
          return
        end
        
        # Build and validate preferences from multiple columns
        preferences, pref_errors = build_preferences(row)
        
        contact = Contact.new(
          organization: import_log.organization,
          created_by: import_log.user,
          first_name: row['first_name'],
          last_name: row['last_name'],
          email: row['email'],
          phone: row['phone'],
          preferences: preferences
        )
        
        # Collect all errors (preference + model validation)
        all_errors = []
        all_errors.concat(pref_errors) if pref_errors.any?
        
        if contact.valid?
          contact.save
          successful += 1
        else
          all_errors.concat(contact.errors.full_messages)
        end
        
        # Add to error log if there are any errors
        if all_errors.any?
          errors << {
            row_number: total,
            data: row.to_h.slice('first_name', 'last_name', 'email', 'phone'),
            errors: all_errors
          }
        end
      end
    end
    
    import_log.update!(
      status: :completed,
      total_rows: total,
      successful_rows: successful,
      failed_rows: errors.count,
      error_details: errors
    )
    
    Rails.logger.info "ContactImportJob: Completed import for log #{import_log_id}. Total: #{total}, Success: #{successful}, Failed: #{errors.count}"
  rescue => e
    Rails.logger.error "ContactImportJob: Failed import for log #{import_log_id}. Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    import_log.update!(
      status: :failed,
      error_details: [{
        error: e.message,
        backtrace: e.backtrace.first(5)
      }]
    )
  ensure
    # Clean up temp file
    File.delete(file_path) if File.exist?(file_path)
  end
  
  private
  
  def valid_headers?(headers)
    REQUIRED_HEADERS.all? { |h| headers.include?(h) }
  end
  
  def build_preferences(row)
    prefs = {}
    errors = []
    
    # Contact type (enum)
    if row['contact_type'].present?
      contact_type = row['contact_type'].downcase
      if CONTACT_TYPES.include?(contact_type)
        prefs['contact_type'] = contact_type
      else
        errors << "Invalid contact_type: #{row['contact_type']}. Must be one of: #{CONTACT_TYPES.join(', ')}"
      end
    end
    
    # Min budget (integer)
    if row['min_budget'].present?
      min_budget = row['min_budget'].to_i
      if min_budget > 0
        prefs['min_budget'] = min_budget
      else
        errors << "Invalid min_budget: must be a positive number"
      end
    end
    
    # Max budget (integer)
    if row['max_budget'].present?
      max_budget = row['max_budget'].to_i
      if max_budget > 0
        prefs['max_budget'] = max_budget
        
        # Validate min_budget <= max_budget
        if prefs['min_budget'] && prefs['min_budget'] > max_budget
          errors << "min_budget cannot be greater than max_budget"
        end
      else
        errors << "Invalid max_budget: must be a positive number"
      end
    end
    
    # Property location (array of enums - comma separated)
    if row['property_locations'].present?
      locations = row['property_locations'].split(',').map { |loc| loc.downcase.strip }
      invalid_locations = locations.reject { |loc| PROPERTY_LOCATIONS.include?(loc) }
      
      if invalid_locations.any?
        errors << "Invalid property_locations(s): #{invalid_locations.join(', ')}. Must be one of: #{PROPERTY_LOCATIONS.join(', ')}"
      else
        prefs['property_locations'] = locations
      end
    end
    
    # Property types (array of enums - comma separated)
    if row['property_types'].present?
      types = row['property_types'].split(',').map { |type| type.downcase.gsub(/\s+/, '') }
      invalid_types = types.reject { |type| PROPERTY_TYPES.include?(type) }
      
      if invalid_types.any?
        errors << "Invalid property_types(s): #{invalid_types.join(', ')}. Must be one of: #{PROPERTY_TYPES.join(', ')}"
      else
        prefs['property_types'] = types
      end
    end
    
    # Timeline (enum)
    if row['timeline'].present?
      timeline = row['timeline'].strip
      if TIMELINES.include?(timeline)
        prefs['timeline'] = timeline
      else
        errors << "Invalid timeline: #{row['timeline']}. Must be one of: #{TIMELINES.join(', ')}"
      end
    end
    
    [prefs, errors]
  end
end
