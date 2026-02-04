class RenameOrgIdToOrganizationId < ActiveRecord::Migration[8.1]
  def change
    # Remove the old index
    remove_index :users, name: 'index_users_on_org_id', if_exists: true
    
    # Remove the old foreign key
    remove_foreign_key :users, column: :org_id, if_exists: true
    
    # Rename the column
    rename_column :users, :org_id, :organization_id
    
    # Add the new index
    add_index :users, :organization_id, name: 'index_users_on_organization_id'
    
    # Add the new foreign key
    add_foreign_key :users, :organizations, column: :organization_id, on_delete: :nullify
  end
end
