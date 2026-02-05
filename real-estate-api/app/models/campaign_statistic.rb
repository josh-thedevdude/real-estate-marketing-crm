class CampaignStatistic < ApplicationRecord
  # Associations
  belongs_to :campaign
  
  # Validations
  validates :campaign, presence: true, uniqueness: true
  
  # Update statistics from campaign emails
  def update_from_emails!
    emails = campaign.campaign_emails
    
    update!(
      total_contacts: emails.count,
      emails_sent: emails.sent.count,
      emails_failed: emails.failed.count,
      last_sent_at: emails.maximum(:sent_at)
    )
  end
  
  def success_rate
    return 0 if total_contacts.zero?
    ((total_contacts - emails_failed).to_f / total_contacts * 100).round(2)
  end
end
