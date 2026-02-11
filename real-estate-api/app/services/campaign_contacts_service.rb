class CampaignContactsService
  attr_reader :campaign
  
  def initialize(campaign)
    @campaign = campaign
  end
  
  # Get unique contacts from all audiences
  def unique_contacts
    contact_ids = Set.new
    audience_contacts = {}
    
    # Get contacts from all campaign audiences
    campaign.audiences.each do |audience|
      # Get contacts from filters (dynamic)
      filter_contacts = AudienceQueryService.new(audience).contacts
      
      # Get manually selected contacts from audience_contacts table
      manual_contacts = audience.contacts
      
      # Combine both sets
      all_contacts = (filter_contacts.to_a + manual_contacts.to_a).uniq
      
      all_contacts.each do |contact|
        unless contact_ids.include?(contact.id)
          contact_ids.add(contact.id)
          audience_contacts[contact.id] = {
            contact: contact,
            audience: audience
          }
        end
      end
    end
    
    audience_contacts.values
  end
  
  def total_count
    unique_contacts.count
  end
  
  # Preview contacts for given audience IDs
  def self.preview(audience_ids, organization)
    contact_ids = Set.new
    contacts = []
    
    Audience.where(id: audience_ids, organization: organization).each do |audience|
      # Get contacts from filters (dynamic)
      filter_contacts = AudienceQueryService.new(audience).contacts
      
      # Get manually selected contacts from audience_contacts table
      manual_contacts = audience.contacts
      
      # Combine both sets
      audience_contacts = (filter_contacts.to_a + manual_contacts.to_a).uniq
      
      audience_contacts.each do |contact|
        unless contact_ids.include?(contact.id)
          contact_ids.add(contact.id)
          contacts << contact
        end
      end
    end
    
    contacts
  end
end
