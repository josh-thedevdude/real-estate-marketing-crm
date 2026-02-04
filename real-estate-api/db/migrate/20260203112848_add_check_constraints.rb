class AddCheckConstraints < ActiveRecord::Migration[8.1]
  def change
    # Ensure scheduled_at is in the future when set
    add_check_constraint :campaigns, 
                         "scheduled_at IS NULL OR scheduled_at > created_at", 
                         name: "scheduled_at_after_created"
    
    # Ensure email format is valid (basic check)
    add_check_constraint :contacts,
                         "email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$'",
                         name: "valid_email_format"
    
    add_check_constraint :users,
                         "email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$'",
                         name: "valid_user_email_format"
    
    # Ensure role is within valid range (assuming 0-2 based on default)
    add_check_constraint :users,
                         "role >= 0 AND role <= 2",
                         name: "valid_role_range"
    
    # Ensure status is within valid range
    add_check_constraint :users,
                         "status >= 0",
                         name: "valid_user_status"
    
    add_check_constraint :campaigns,
                         "status >= 0",
                         name: "valid_campaign_status"
    
    add_check_constraint :campaigns,
                         "scheduled_type >= 0",
                         name: "valid_scheduled_type"
    
    # Ensure phone number format (E.164 format, if applicable)
    # Adjust pattern based on your requirements
    add_check_constraint :contacts,
                         "phone IS NULL OR phone ~* '^\\+?[1-9]\\d{1,14}$'",
                         name: "valid_phone_format"
  end
end
