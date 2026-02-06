class CampaignExecutionJob < ApplicationJob
  queue_as :default
  
  def perform(campaign_id)
    campaign = ActsAsTenant.without_tenant { Campaign.find(campaign_id) }
    
    return unless campaign.running?
    
    ActsAsTenant.with_tenant(campaign.organization) do
      pending_emails = campaign.campaign_emails.pending
      
      Rails.logger.info("Starting campaign execution for campaign ##{campaign.id}: #{pending_emails.count} emails to send")
      
      pending_emails.find_each do |campaign_email|
        begin
          # Send email via mailer
          CampaignMailer.send_campaign_email(campaign_email).deliver_now
          
          campaign_email.mark_sent!
          Rails.logger.info("Email sent to #{campaign_email.email}")
        rescue => e
          campaign_email.mark_failed!(e.message)
          Rails.logger.error("Failed to send email to #{campaign_email.email}: #{e.message}")
        end
        
        # Rate limiting - prevent overwhelming email servers
        sleep(0.1)
      end
      
      # Update statistics
      campaign.campaign_statistic.update_from_emails!
      
      # Update campaign status
      update_campaign_status(campaign)
      
      Rails.logger.info("Campaign execution completed for campaign ##{campaign.id}")
    end
  end
  
  private
  
  def update_campaign_status(campaign)
    stats = campaign.campaign_statistic
    
    if stats.emails_failed == stats.total_contacts
      campaign.update!(status: :failed)
    elsif stats.emails_failed > 0
      campaign.update!(status: :partial)
    else
      campaign.update!(status: :completed)
    end
  end
end
