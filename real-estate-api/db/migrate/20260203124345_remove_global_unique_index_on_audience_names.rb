class RemoveGlobalUniqueIndexOnAudienceNames < ActiveRecord::Migration[8.1]
  def change
    remove_index :audiences, :name

    add_index :audiences,
              [:organization_id, :name],
              unique: true,
              where: "deleted_at IS NULL",
              name: "index_audiences_on_org_and_name"
  end
end
