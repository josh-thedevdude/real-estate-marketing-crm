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
      
      # Return false if no contacts
      if contacts_data.empty?
        Rails.logger.warn("Campaign #{campaign.id} has no contacts to send to")
        return false
      end
      
      # Create campaign emails
      contacts_data.each do |data|
        contact = data[:contact]
        audience = data[:audience]
        
        # Determine subject and body
        if campaign.email_template.present?
          # Render email template with campaign custom variables
          rendered = campaign.email_template.render_for_contact(contact, campaign.custom_variables)
          subject = rendered[:subject]
          body = rendered[:body]
        else
          # Use campaign's direct subject and body
          subject = campaign.subject
          body = campaign.body
          
          # Simple variable replacement for {{contact_name}}
          if subject.present?
            subject = subject.gsub('{{contact_name}}', contact.full_name || contact.email)
          end
          if body.present?
            body = body.gsub('{{contact_name}}', contact.full_name || contact.email)
          end
        end
        
        CampaignEmail.create!(
          campaign: campaign,
          contact: contact,
          audience: audience,
          email: contact.email,
          subject: subject,
          body: body,
          status: :pending
        )
      end
      
      # Create statistics record
      CampaignStatistic.create!(
        campaign: campaign,
        total_contacts: contacts_data.count
      )
      
      # Increment occurrence count for recurring campaigns
      if campaign.recurring?
        campaign.increment!(:occurrence_count)
      end
      
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
