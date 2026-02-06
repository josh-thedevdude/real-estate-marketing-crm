#!/bin/bash
# ==============================================================================
# AUTOMATED MIGRATION SETUP SCRIPT
# ==============================================================================
# This script will:
# 1. Generate migration files
# 2. Replace their content with the correct code
# 3. Run the migrations
# ==============================================================================

set -e  # Exit on any error

echo "Starting migration setup..."

# Generate migration files
echo "Generating migration files..."
rails g migration AddSubjectAndBodyToCampaigns
rails g migration CreateAudienceContacts

# Find the generated migration files
MIGRATION1=$(ls -t db/migrate/*_add_subject_and_body_to_campaigns.rb | head -1)
MIGRATION2=$(ls -t db/migrate/*_create_audience_contacts.rb | head -1)

echo "Found migrations:"
echo "   - $MIGRATION1"
echo "   - $MIGRATION2"

# Replace content of first migration
echo "Writing AddSubjectAndBodyToCampaigns..."
cat > "$MIGRATION1" << 'EOF'
class AddSubjectAndBodyToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :subject, :string
    add_column :campaigns, :body, :text
  end
end
EOF

# Replace content of second migration
echo "Writing CreateAudienceContacts..."
cat > "$MIGRATION2" << 'EOF'
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
EOF

# Run migrations
echo "Running migrations..."
rails db:migrate

echo "Migration setup complete!"
echo ""
echo "Migration status:"
rails db:migrate:status | tail -5
