class CampaignEmail < ApplicationRecord
  # Associations
  belongs_to :campaign
  belongs_to :contact
  belongs_to :audience, optional: true
  
  # Enums
  enum :status, {
    pending: 0,
    sent: 1,
    failed: 2
  }, default: :pending
  
  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true
  validates :body, presence: true
  validates :campaign_id, uniqueness: { scope: :contact_id }
  
  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :sent_today, -> { where("sent_at >= ?", Time.current.beginning_of_day) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Mark as sent
  def mark_sent!
    update!(status: :sent, sent_at: Time.current)
  end
  
  def mark_failed!(error)
    update!(status: :failed, error_message: error)
  end
end
