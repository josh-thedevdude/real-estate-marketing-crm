class AudienceQueryService
  attr_reader :audience
  
  def initialize(audience)
    @audience = audience
  end
  
  def contacts
    # Audience Should belong to some organization
    return Contact.none unless audience.organization
    
    # tenant isolation
    query = Contact.where(organization: audience.organization)

    # apply filters
    query = apply_filters(query, audience.filters)

    # return query
    query
  end
  
  def count
    contacts.count
  end
  
  private
  
  def apply_filters(query, filters)
    # All Contacts If Blank Filters
    return query if filters.blank?
    
    # Contact type filter
    if filters['contact_type'].present?
      query = query.where("preferences->>'contact_type' = ?", filters['contact_type'])
    end
    
    # Property locations filter (array overlap)
    if filters['property_locations'].present? && filters['property_locations'].is_a?(Array)
      # Check if any of the filter locations exist in the contact's property_locations array
      query = query.where(
        "preferences->'property_locations' ?| array[:locations]",
        locations: filters['property_locations']
      )
    end
    
    # Property types filter (array overlap)
    if filters['property_types'].present? && filters['property_types'].is_a?(Array)
      query = query.where(
        "preferences->'property_types' ?| array[:types]",
        types: filters['property_types']
      )
    end
    
    # Timeline filter
    if filters['timeline'].present?
      query = query.where("preferences->>'timeline' = ?", filters['timeline'])
    end
    
    # Min budget filter
    if filters['min_budget'].present?
      query = query.where("(preferences->>'min_budget')::integer >= ?", filters['min_budget'])
    end
    
    # Max budget filter
    if filters['max_budget'].present?
      query = query.where("(preferences->>'max_budget')::integer <= ?", filters['max_budget'])
    end
    
    # Return the query
    query
  end
end
