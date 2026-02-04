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

  # Validations  
  validates :first_name, length: { minimum: 3, maximum: 50 }
  validates :last_name, length: { minimum: 3, maximum: 50 }
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

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
