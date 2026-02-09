class Audience < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at

  # Multi-tenancy
  acts_as_tenant :organization

  # Associations
  belongs_to :created_by, class_name: 'User'

  has_many :campaign_audiences, dependent: :delete_all
  has_many :campaigns, through: :campaign_audiences

  # Validations
  validates :name,
          presence: true,
          length: { minimum: 3, maximum: 100 },
          uniqueness: {
            scope: [:organization_id, :deleted_at],
            conditions: -> { where(deleted_at: nil) }
          }
  validates :description, length: { minimum: 10, maximum: 255 }, allow_blank: true
  # validates :organization, presence: true
  validates :created_by, presence: true
  
  # Filter validations
  validate :at_least_one_filter_present

  # Scopes
  default_scope { kept }
  scope :by_user, ->(user_id) { where(created_by_id: user_id) }
  scope :search, ->(query) {
    where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  }
  
  # Helper methods
  def contact_count
    AudienceQueryService.new(self).count
  end
  
  def contacts(page: 1, per_page: 20)
    AudienceQueryService.new(self).contacts.page(page).per(per_page)
  end
  
  private
  
  def at_least_one_filter_present
    return if filters.blank?
    
    valid_filters = %w[
      contact_type property_locations property_types 
      timeline min_budget max_budget
    ]
    
    has_filter = valid_filters.any? { |key| filters[key].present? }
    
    unless has_filter
      errors.add(:filters, 'must contain at least one valid filter: contact_type, property_locations, property_types, timeline, min_budget, or max_budget')
      return
    end
    
    # Validate contact_type enum
    if filters['contact_type'].present?
      unless Contact::CONTACT_TYPES.include?(filters['contact_type'])
        errors.add(:filters, "contact_type must be one of: #{Contact::CONTACT_TYPES.join(', ')}")
      end
    end
    
    # Validate property_locations enum (array)
    if filters['property_locations'].present?
      unless filters['property_locations'].is_a?(Array)
        errors.add(:filters, 'property_locations must be an array')
      else
        invalid_locations = filters['property_locations'] - Contact::PROPERTY_LOCATIONS
        if invalid_locations.any?
          errors.add(:filters, "property_locations contains invalid values: #{invalid_locations.join(', ')}. Valid values: #{Contact::PROPERTY_LOCATIONS.join(', ')}")
        end
      end
    end
    
    # Validate property_types enum (array)
    if filters['property_types'].present?
      unless filters['property_types'].is_a?(Array)
        errors.add(:filters, 'property_types must be an array')
      else
        invalid_types = filters['property_types'] - Contact::PROPERTY_TYPES
        if invalid_types.any?
          errors.add(:filters, "property_types contains invalid values: #{invalid_types.join(', ')}. Valid values: #{Contact::PROPERTY_TYPES.join(', ')}")
        end
      end
    end
    
    # Validate timeline enum
    if filters['timeline'].present?
      unless Contact::TIMELINES.keys.include?(filters['timeline'])
        errors.add(:filters, "timeline must be one of: #{Contact::TIMELINES.keys.join(', ')}")
      end
    end
    
    # Validate min_budget
    if filters['min_budget'].present?
      unless filters['min_budget'].to_i > 0
        errors.add(:filters, 'min_budget must be greater than 0')
      end
    end
    
    # Validate max_budget
    if filters['max_budget'].present?
      unless filters['max_budget'].to_i > 0
        errors.add(:filters, 'max_budget must be greater than 0')
      end
      
      if filters['min_budget'].present? && filters['max_budget'].to_i < filters['min_budget'].to_i
        errors.add(:filters, 'max_budget must be greater than or equal to min_budget')
      end
    end
  end
end
