class CampaignContactsService
  attr_reader :campaign
  
  def initialize(campaign)
    @campaign = campaign
  end
  
  # Get unique contacts from all audiences
  def unique_contacts
    # Track Contact Ids
    contact_ids = Set.new
    # contact with its matched audience
    audience_contacts = {}
    
    # Iterate over all audiences
    campaign.audiences.each do |audience|
      # Get contacts for the audience
      contacts = AudienceQueryService.new(audience).contacts
      
      contacts.each do |contact|
        # Add contact to the hash if not already present
        unless contact_ids.include?(contact.id)
          # visited
          contact_ids.add(contact.id) 
          # contact with its matching audience
          audience_contacts[contact.id] = {
            contact: contact,
            audience: audience
          }
        end
      end
    end
    
    # Return the values of the hash
    audience_contacts.values
  end
  
  # Get total count of unique contacts
  def total_count
    unique_contacts.count
  end
  
  # Preview contacts for given audience IDs
  def self.preview(audience_ids, organization)
    contact_ids = Set.new
    contacts = []
    
    Audience.where(id: audience_ids, organization: organization).each do |audience|
      # Get contacts for the audience
      audience_contacts = AudienceQueryService.new(audience).contacts
      
      # Iterate over all contacts
      audience_contacts.each do |contact|
        # Add contact to the array if not already present
        unless contact_ids.include?(contact.id)
          contact_ids.add(contact.id)
          contacts << contact
        end
      end
    end
    
    contacts
  end
end
