class EmailTemplate < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at
  
  # Multi-tenancy
  acts_as_tenant :organization
  
  # Associations
  belongs_to :organization
  belongs_to :created_by, class_name: 'User'
  has_many :campaigns, dependent: :nullify
  
  # Validations
  validates :name, presence: true,
            uniqueness: {
              scope: [:organization_id, :created_by_id],
              conditions: -> { where(deleted_at: nil) }
            },
            length: { minimum: 3, maximum: 100 }
  validates :subject, presence: true, length: { minimum: 3, maximum: 200 }
  validates :body, presence: true, length: { minimum: 10 }
  
  # Scopes
  default_scope { kept }
  scope :by_user, ->(user_id) { where(created_by_id: user_id) }
  scope :search, ->(query) {
    where("name ILIKE ? OR subject ILIKE ?", "%#{query}%", "%#{query}%")
  }
  
  # Render template with variables
  def render_for_contact(contact, custom_vars = {})
    vars = default_variables(contact).merge(custom_vars)
    
    {
      subject: interpolate(subject, vars),
      body: interpolate(body, vars)
    }
  end
  
  private
  
  def default_variables(contact)
    {
      'first_name' => contact.first_name,
      'last_name' => contact.last_name,
      'full_name' => contact.full_name,
      'email' => contact.email,
      'phone' => contact.phone || ''
    }
  end
  
  def interpolate(text, vars)
    result = text.dup
    vars.each do |key, value|
      result.gsub!("{{#{key}}}", value.to_s)
    end
    result
  end
end
