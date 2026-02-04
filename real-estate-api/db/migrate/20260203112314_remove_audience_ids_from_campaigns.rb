class RemoveAudienceIdsFromCampaigns < ActiveRecord::Migration[8.1]
  def change
    # Remove the index first
    remove_index :campaigns, name: 'index_campaigns_on_audience_ids', if_exists: true
    
    # Remove the column
    remove_column :campaigns, :audience_ids, :integer, array: true, default: []
  end
end
