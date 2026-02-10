class Campaign < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at

  # Multi-tenancy
  acts_as_tenant :organization

  # Enums
  enum :status, { created: 0, running: 1, completed: 2, failed: 3, partial: 4 }, default: :created
  enum :scheduled_type, { immediate: 0, scheduled: 1, recurring: 2 }, default: :immediate
  enum :recurrence_interval, {
    minutely: 0,
    hourly: 1,
    daily: 2,
    weekly: 3,
    biweekly: 4,
    monthly: 5
  }, prefix: true

  # Associations
  belongs_to :created_by, class_name: 'User'
  belongs_to :email_template, optional: true

  has_many :campaign_audiences, dependent: :destroy
  has_many :audiences, through: :campaign_audiences
  has_many :campaign_emails, dependent: :destroy
  has_one :campaign_statistic, dependent: :destroy
  
  # Validations
  # campaign should be present and unique for a user within an organization
  validates :name, presence: true, uniqueness: { scope: [:organization_id, :created_by_id], conditions: -> { where(deleted_at: nil) } }, 
            length: { minimum: 3, maximum: 100 }
  # validate description if present
  validates :description, length: { minimum: 10, maximum: 255 }, allow_blank: true
  # campaign should be associated with an organization
  validates :organization, presence: true
  # campaign should be created by a user
  validates :created_by, presence: true
  # campaign should have a scheduled type
  validates :scheduled_type, presence: true
  # campaign should have a scheduled time if scheduled or recurring
  validates :scheduled_at, presence: true, if: -> { scheduled? || recurring? }
  # recurring campaign should have a recurrence interval
  validates :recurrence_interval, presence: true, if: :recurring?
  # should be scheduled after the current time for scheduled and recurring campaigns
  validate :recurrence_end_date_after_scheduled_at, if: :recurring? 
  # todo handle recurring campaigns based on end date
  validate :max_occurrences_positive, if: :recurring?
  
  # email template should belong to the user
  validate :email_template_belongs_to_user
  # audiences should belong to the user
  validate :audiences_belong_to_user

  # Scopes
  # ignore deleted campaigns
  default_scope { kept }
  # campaigns created by specific user
  scope :by_user, ->(user_id) { where(created_by_id: user_id) }
  # search campaign by specific query
  scope :search, ->(query) {
    where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  }
  # campaigns with specific status
  scope :by_status, ->(status) { where(status: status) }
  # campaigns scheduled between specific time
  scope :scheduled_between, ->(start_time, end_time) { where(scheduled_at: start_time..end_time) }
  # select due campaigns for execution
  scope :due_for_execution, -> {
    where(status: :created)
      .where("scheduled_at IS NULL OR scheduled_at <= ?", Time.current)
      .where(deleted_at: nil)
  }
  
  # Helper methods
  def total_contacts
    campaign_statistic&.total_contacts || 0
  end
  
  def emails_sent
    campaign_statistic&.emails_sent || 0
  end
  
  def emails_failed
    campaign_statistic&.emails_failed || 0
  end

  def success_rate
    campaign_statistic&.success_rate || 0
  end

  def last_sent_at
    campaign_statistic&.last_sent_at || nil
  end
  
  def can_execute?
    created? && audiences.any? && email_template.present?
  end
  
  def can_update?
    created?
  end
  
  # Recurring campaign methods
  def next_scheduled_time
    return nil unless recurring? && scheduled_at.present?
    
    case recurrence_interval
    when 'minutely'
      scheduled_at + 1.minute
    when 'hourly'
      scheduled_at + 1.hour
    when 'daily'
      scheduled_at + 1.day
    when 'weekly'
      scheduled_at + 1.week
    when 'biweekly'
      scheduled_at + 2.weeks
    when 'monthly'
      scheduled_at + 1.month
    else
      scheduled_at + 1.day # default fallback
    end
  end
  
  def should_continue_recurring?
    return false unless recurring?
    
    # Check if end date has passed
    if recurrence_end_date.present? && Time.current >= recurrence_end_date
      return false
    end
    
    # Check if max occurrences reached
    if max_occurrences.present? && occurrence_count >= max_occurrences
      return false
    end
    
    true
  end
  
  private
  
  def recurrence_end_date_after_scheduled_at
    if recurrence_end_date.present? && scheduled_at.present? && recurrence_end_date <= scheduled_at
      errors.add(:recurrence_end_date, 'must be after scheduled_at')
    end
  end
  
  def max_occurrences_positive
    if max_occurrences.present? && max_occurrences <= 0
      errors.add(:max_occurrences, 'must be greater than 0')
    end
  end
  
  def email_template_belongs_to_user
    return if email_template_id.blank?
    
    template = EmailTemplate.find_by(id: email_template_id)
    unless template && template.created_by_id == created_by_id
      errors.add(:email_template_id, 'must be a template you created')
    end
  end
  
  def audiences_belong_to_user
    return if campaign_audiences.blank?
    
    audience_ids = campaign_audiences.map(&:audience_id)
    return if audience_ids.blank?
    
    user_audiences = Audience.where(id: audience_ids, created_by_id: created_by_id)
    
    if user_audiences.count != audience_ids.uniq.count
      errors.add(:audiences, 'must all be audiences you created')
    end
  end
end
