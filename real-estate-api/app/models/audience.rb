# == Schema Information
#
# Table name: audiences
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  created_by_id   :integer          not null
#  deleted_at      :datetime
#  description     :text
#  filters         :jsonb            default("{}"), not null
#  name            :string           not null
#  organization_id :integer          not null
#  updated_at      :datetime         not null
#

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

  # Scopes
  default_scope { kept }
end
