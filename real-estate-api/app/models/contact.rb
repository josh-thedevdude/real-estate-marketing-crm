# == Schema Information
#
# Table name: contacts
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  created_by_id   :integer          not null
#  deleted_at      :datetime
#  email           :string           not null
#  first_name      :string
#  last_name       :string
#  organization_id :integer          not null
#  phone           :string
#  preferences     :jsonb            default("{}"), not null
#  updated_at      :datetime         not null
#

class Contact < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at

  # Multi-tenancy
  acts_as_tenant :organization

  # Associations
  belongs_to :created_by, class_name: 'User'
  
  has_many :audience_contacts, dependent: :delete_all
  has_many :audiences, through: :audience_contacts

  # Validations  
  validates :first_name, length: { minimum: 3, maximum: 50 }, allow_blank: true
  validates :last_name, length: { minimum: 3, maximum: 50 }, allow_blank: true
  validates :email,
            presence: true,
            uniqueness: {
              scope: [:organization_id, :deleted_at],
              conditions: -> { where(deleted_at: nil) }
            },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone,
            uniqueness: {
              scope: [:organization_id, :deleted_at],
              conditions: -> { where(deleted_at: nil) },
              allow_nil: true
            }
  # validates :organization, presence: true
  validates :created_by, presence: true

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
end
