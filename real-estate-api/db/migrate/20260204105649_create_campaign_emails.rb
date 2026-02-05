class CreateCampaignEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_emails do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.references :audience, null: true, foreign_key: true
      t.string :email, null: false
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :status, default: 0, null: false
      t.datetime :sent_at
      t.datetime :delivered_at
      t.datetime :opened_at
      t.datetime :clicked_at
      t.datetime :bounced_at
      t.text :error_message

      t.timestamps
    end
    
    add_index :campaign_emails, [:campaign_id, :contact_id], 
              unique: true,
              name: "index_campaign_emails_on_campaign_and_contact"
    add_index :campaign_emails, [:campaign_id, :status]
    add_index :campaign_emails, :status
    add_index :campaign_emails, :sent_at
  end
end
