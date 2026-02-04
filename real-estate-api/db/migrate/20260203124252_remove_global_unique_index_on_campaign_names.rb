class RemoveGlobalUniqueIndexOnCampaignNames < ActiveRecord::Migration[8.1]
  def change
    remove_index :campaigns, :name

    add_index :campaigns,
              [:organization_id, :name],
              unique: true,
              where: "deleted_at IS NULL",
              name: "index_campaigns_on_org_and_name"
  end
end
