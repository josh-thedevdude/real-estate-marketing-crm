class AudienceQueryService
  attr_reader :audience
  
  def initialize(audience)
    @audience = audience
  end
  
  def contacts
    return Contact.none unless audience.organization
    
    query = Contact.where(organization: audience.organization)
    query = apply_filters(query, audience.filters)
    query
  end
  
  def count
    contacts.count
  end
  
  private
  
  def apply_filters(query, filters)
    return query if filters.blank?
    
    # Contact type filter
    if filters['contact_type'].present?
      query = query.where("preferences->>'contact_type' = ?", filters['contact_type'])
    end
    
    # Min budget range filter
    if filters['min_budget_range'].present? && filters['min_budget_range'].is_a?(Array)
      min_val, max_val = filters['min_budget_range']
      if min_val.present? && max_val.present?
        query = query.where(
          "(preferences->>'min_budget')::integer BETWEEN ? AND ?",
          min_val, max_val
        )
      elsif min_val.present?
        query = query.where("(preferences->>'min_budget')::integer >= ?", min_val)
      elsif max_val.present?
        query = query.where("(preferences->>'min_budget')::integer <= ?", max_val)
      end
    end
    
    # Max budget range filter
    if filters['max_budget_range'].present? && filters['max_budget_range'].is_a?(Array)
      min_val, max_val = filters['max_budget_range']
      if min_val.present? && max_val.present?
        query = query.where(
          "(preferences->>'max_budget')::integer BETWEEN ? AND ?",
          min_val, max_val
        )
      elsif min_val.present?
        query = query.where("(preferences->>'max_budget')::integer >= ?", min_val)
      elsif max_val.present?
        query = query.where("(preferences->>'max_budget')::integer <= ?", max_val)
      end
    end
    
    # Property locations filter (array overlap)
    if filters['property_locations'].present? && filters['property_locations'].is_a?(Array)
      # Check if any of the filter locations exist in the contact's property_location array
      query = query.where(
        "preferences->'property_location' ?| array[:locations]",
        locations: filters['property_locations']
      )
    end
    
    # Property types filter
    if filters['property_types'].present? && filters['property_types'].is_a?(Array)
      query = query.where(
        "preferences->>'property_type' IN (?)",
        filters['property_types']
      )
    end
    
    # Timelines filter
    if filters['timelines'].present? && filters['timelines'].is_a?(Array)
      query = query.where(
        "preferences->>'timeline' IN (?)",
        filters['timelines']
      )
    end
    
    query
  end
end
