# == Schema Information
#
# Table name: campaigns
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  created_by_id   :integer          not null
#  deleted_at      :datetime
#  description     :text
#  name            :string           not null
#  organization_id :integer          not null
#  scheduled_at    :datetime
#  scheduled_type  :integer          default(0), not null
#  status          :integer          default(0), not null
#  updated_at      :datetime         not null
#

class Campaign < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at

  # Multi-tenancy
  acts_as_tenant :organization

  # Enums
  enum :status, { created: 0, running: 1, completed: 2, failed: 3, partial: 4 }, default: :created
  enum :scheduled_type, { immediate: 0, scheduled: 1, recurring: 2 }, default: :scheduled

  # Associations
  belongs_to :organization
  belongs_to :created_by, class_name: 'User'

  has_many :campaign_audiences, dependent: :delete_all
  has_many :audiences, through: :campaign_audiences
  
  # Validations
  validates :name, presence: true, 
          uniqueness: {
            scope: [:organization_id, :deleted_at],
            conditions: -> { where(deleted_at: nil) }
          },
          length: { minimum: 3, maximum: 100 }
  validates :description, length: { minimum: 10, maximum: 255 }, allow_blank: true
  # validates :organization, presence: true
  validates :created_by, presence: true
  validates :scheduled_type, presence: true
  validates :scheduled_at, presence: true, if: -> { scheduled? || recurring? }
  validates :status, presence: true

  # Scopes
  default_scope { kept }
  scope :by_status, ->(status) { where(status: status) }
  scope :scheduled_between, ->(start_time, end_time) { where(scheduled_at: start_time..end_time) }
end
