class CreateCampaignAudiences < ActiveRecord::Migration[8.1]
  def change
    create_table :campaign_audiences do |t|
      t.bigint :campaign_id, null: false
      t.bigint :audience_id, null: false
      t.datetime :created_at, null: false

      # Composite index to prevent duplicate associations
      t.index [:campaign_id, :audience_id], unique: true, name: 'index_campaign_audiences_on_campaign_and_audience'
      
      # Index for reverse lookups (finding campaigns by audience)
      t.index :audience_id, name: 'index_campaign_audiences_on_audience_id'
    end

    add_foreign_key :campaign_audiences, :campaigns, on_delete: :cascade
    add_foreign_key :campaign_audiences, :audiences, on_delete: :cascade
  end
end
