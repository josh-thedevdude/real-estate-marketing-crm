class AddCompositeIndexes < ActiveRecord::Migration[8.1]
  def change
    # Audiences - organization + deleted_at queries
    add_index :audiences, [:organization_id, :deleted_at], 
              name: 'index_audiences_on_org_and_deleted'
    
    # Campaigns - multiple composite indexes for common queries
    add_index :campaigns, [:organization_id, :deleted_at], 
              name: 'index_campaigns_on_org_and_deleted'
    
    add_index :campaigns, [:organization_id, :status, :deleted_at], 
              name: 'index_campaigns_on_org_status_deleted'
    
    # Index for scheduled campaigns that need to be processed
    add_index :campaigns, [:scheduled_at, :status], 
              where: "deleted_at IS NULL AND scheduled_at IS NOT NULL",
              name: 'index_campaigns_on_scheduled_pending'
    
    # Contacts - organization + deleted_at queries
    add_index :contacts, [:organization_id, :deleted_at], 
              name: 'index_contacts_on_org_and_deleted'
    
    # Users - organization + deleted_at queries
    add_index :users, [:org_id, :deleted_at], 
              name: 'index_users_on_org_and_deleted'
    
    # Users - status and deleted_at for active user lookups
    add_index :users, [:status, :deleted_at], 
              name: 'index_users_on_status_and_deleted'
    
    # Users - pending invitations
    add_index :users, [:invitation_token, :invitation_accepted_at], 
              where: "invitation_accepted_at IS NULL AND invitation_token IS NOT NULL",
              name: 'index_users_on_pending_invitations'
  end
end
