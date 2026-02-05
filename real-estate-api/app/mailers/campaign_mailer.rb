class CampaignMailer < ApplicationMailer
  default from: 'noreply@realestate.com'
  
  def send_campaign_email(campaign_email)
    @campaign_email = campaign_email
    @contact = campaign_email.contact
    @campaign = campaign_email.campaign
    
    mail(
      to: campaign_email.email,
      subject: campaign_email.subject
    ) do |format|
      format.html { render html: campaign_email.body.html_safe }
      format.text { render plain: campaign_email.body }
    end
  end
end
