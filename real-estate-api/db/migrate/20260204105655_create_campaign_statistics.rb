class CreateCampaignStatistics < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_statistics do |t|
      t.references :campaign, null: false, foreign_key: true, index: { unique: true }
      t.integer :total_contacts, default: 0, null: false
      t.integer :emails_sent, default: 0, null: false
      t.integer :emails_delivered, default: 0, null: false
      t.integer :emails_opened, default: 0, null: false
      t.integer :emails_clicked, default: 0, null: false
      t.integer :emails_bounced, default: 0, null: false
      t.integer :emails_failed, default: 0, null: false
      t.datetime :last_sent_at

      t.timestamps
    end
  end
end
