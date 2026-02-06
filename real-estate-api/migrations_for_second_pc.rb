# ==============================================================================
# MIGRATIONS CREATED IN THIS SESSION
# ==============================================================================
# Instructions:
# 1. Navigate to your project on the second PC
# 2. Generate new migration files with these commands:
#    rails g migration AddSubjectAndBodyToCampaigns
#    rails g migration CreateAudienceContacts
# 3. Replace the generated content with the code below
# 4. Run: rails db:migrate
# ==============================================================================

# ==============================================================================
# MIGRATION 1: Add subject and body columns to campaigns table
# File name: YYYYMMDDHHMMSS_add_subject_and_body_to_campaigns.rb
# ==============================================================================

class AddSubjectAndBodyToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :subject, :string
    add_column :campaigns, :body, :text
  end
end

# ==============================================================================
# MIGRATION 2: Create audience_contacts join table
# File name: YYYYMMDDHHMMSS_create_audience_contacts.rb
# ==============================================================================

class CreateAudienceContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :audience_contacts do |t|
      t.references :audience, null: false, foreign_key: { on_delete: :cascade }
      t.references :contact, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
    
    add_index :audience_contacts, [:audience_id, :contact_id], unique: true, name: 'index_audience_contacts_on_audience_and_contact'
  end
end

# ==============================================================================
# NOTES:
# ==============================================================================
# - Migration 1: Allows campaigns to work without email templates (direct subject/body)
# - Migration 2: Enables manual contact selection for audiences (many-to-many relationship)
# - Both migrations maintain referential integrity with cascade deletes
# - Unique index prevents duplicate audience-contact associations
# ==============================================================================
