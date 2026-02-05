class CampaignExecutionService
  attr_reader :campaign
  
  def initialize(campaign)
    @campaign = campaign
  end
  
  def prepare!
    return false unless campaign.can_execute?
    
    ActiveRecord::Base.transaction do
      # Get unique contacts
      contacts_data = CampaignContactsService.new(campaign).unique_contacts
      
      # Create campaign emails
      contacts_data.each do |data|
        contact = data[:contact]
        audience = data[:audience]
        
        # Render email template with campaign custom variables
        rendered = campaign.email_template.render_for_contact(contact, campaign.custom_variables)
        
        CampaignEmail.create!(
          campaign: campaign,
          contact: contact,
          audience: audience,
          email: contact.email,
          subject: rendered[:subject],
          body: rendered[:body],
          status: :pending
        )
      end
      
      # Create statistics record
      CampaignStatistic.create!(
        campaign: campaign,
        total_contacts: contacts_data.count
      )
      
      # Update campaign status
      campaign.update!(status: :running)
    end
    
    # Enqueue execution job
    CampaignExecutionJob.perform_later(campaign.id)
    
    true
  rescue => e
    campaign.update(status: :failed)
    Rails.logger.error("Campaign preparation failed: #{e.message}")
    false
  end
end
