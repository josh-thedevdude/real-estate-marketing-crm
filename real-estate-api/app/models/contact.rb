class Contact < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at

  # Multi-tenancy
  acts_as_tenant :organization
  
  # Enums for preferences
  CONTACT_TYPES = %w[buyer seller].freeze
  PROPERTY_LOCATIONS = %w[
    baner wakad hinjewadi kharadi hadapsar wagholi 
    kondhwa undri ravet moshi pimpri_chinchwad akurdi
  ].freeze
  PROPERTY_TYPES = %w[
    apartment villa plot commercial 
    1bhk 2bhk 3bhk 4bhk
  ].freeze
  TIMELINES = {
    'immediate' => 'Immediate',
    'within_3_months' => 'Within 3 Months',
    'within_6_months' => 'Within 6 Months',
    'within_12_months' => 'Within 12 Months'
  }.freeze

  # Associations
  belongs_to :created_by, class_name: 'User'

  # Validations  
  validates :first_name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :email,
            presence: true,
            uniqueness: {
              scope: [:organization_id, :deleted_at],
              conditions: -> { where(deleted_at: nil) }
            },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone,
            presence: true,
            uniqueness: {
              scope: [:organization_id, :deleted_at],
              conditions: -> { where(deleted_at: nil) },
              allow_nil: true
            },
            format: {
              with: /\A(\+91|91)?[6-9][0-9]{9}\z/,
              message: 'must be a valid Indian mobile number (10 digits starting with 6-9, optionally prefixed with +91 or 91)',
              allow_blank: true
            }
  # validates :organization, presence: true
  validates :created_by, presence: true
  
  # Preference validations
  validate :validate_preferences

  # Callbacks
  before_save :downcase_email

  # Scopes
  default_scope { kept }
  scope :by_user, ->(user_id) { where(created_by_id: user_id) }
  scope :search, ->(query) {
    where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
          "%#{query}%", "%#{query}%", "%#{query}%")
  }
  
  # Helper methods
  def full_name
    "#{first_name} #{last_name}".strip
  end
  
  def preference(key)
    preferences[key.to_s]
  end
  
  def set_preference(key, value)
    self.preferences = preferences.merge(key.to_s => value)
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
  
  def validate_preferences
    # Validate contact_type
    if preferences['contact_type'].blank?
      errors.add(:preferences, 'contact_type is required')
    elsif !CONTACT_TYPES.include?(preferences['contact_type'])
      errors.add(:preferences, "contact_type must be one of: #{CONTACT_TYPES.join(', ')}")
    end
    
    # Validate property_locations (array)
    if preferences['property_locations'].blank?
      errors.add(:preferences, 'property_locations is required')
    elsif !preferences['property_locations'].is_a?(Array)
      errors.add(:preferences, 'property_locations must be an array')
    elsif !preferences['property_locations'].all? { |loc| PROPERTY_LOCATIONS.include?(loc) }
      errors.add(:preferences, "property_locations must contain values from: #{PROPERTY_LOCATIONS.join(', ')}")
    end
    
    # Validate property_types (array)
    if preferences['property_types'].blank?
      errors.add(:preferences, 'property_types is required')
    elsif !preferences['property_types'].is_a?(Array)
      errors.add(:preferences, 'property_types must be an array')
    elsif !preferences['property_types'].all? { |type| PROPERTY_TYPES.include?(type) }
      errors.add(:preferences, "property_types must contain values from: #{PROPERTY_TYPES.join(', ')}")
    end
    
    # Validate timeline
    if preferences['timeline'].blank?
      errors.add(:preferences, 'timeline is required')
    elsif !TIMELINES.keys.include?(preferences['timeline'])
      errors.add(:preferences, "timeline must be one of: #{TIMELINES.keys.join(', ')}")
    end
    
    # Validate min_budget
    if preferences['min_budget'].blank?
      errors.add(:preferences, 'min_budget is required')
    elsif preferences['min_budget'].to_i <= 0
      errors.add(:preferences, 'min_budget must be greater than 0')
    end
    
    # Validate max_budget
    if preferences['max_budget'].blank?
      errors.add(:preferences, 'max_budget is required')
    elsif preferences['max_budget'].to_i <= 0
      errors.add(:preferences, 'max_budget must be greater than 0')
    elsif preferences['min_budget'].present? && preferences['max_budget'].to_i < preferences['min_budget'].to_i
      errors.add(:preferences, 'max_budget must be greater than or equal to min_budget')
    end
  end
end
