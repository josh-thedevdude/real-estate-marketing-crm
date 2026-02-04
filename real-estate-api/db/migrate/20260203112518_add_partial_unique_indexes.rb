class AddPartialUniqueIndexes < ActiveRecord::Migration[8.1]
  def up
    # Remove existing unique indexes
    remove_index :audiences, name: 'index_audiences_on_name'
    remove_index :campaigns, name: 'index_campaigns_on_name'
    remove_index :contacts, name: 'index_contacts_on_email'
    remove_index :contacts, name: 'index_contacts_on_phone'
    remove_index :organizations, name: 'index_organizations_on_name'
    remove_index :users, name: 'index_users_on_email'
    
    # Add partial unique indexes (only for non-deleted records)
    add_index :audiences, :name, 
              unique: true, 
              where: "deleted_at IS NULL",
              name: 'index_audiences_on_name'
    
    add_index :campaigns, :name, 
              unique: true, 
              where: "deleted_at IS NULL",
              name: 'index_campaigns_on_name'
    
    add_index :contacts, :email, 
              unique: true, 
              where: "deleted_at IS NULL",
              name: 'index_contacts_on_email'
    
    add_index :contacts, :phone, 
              unique: true, 
              where: "deleted_at IS NULL AND phone IS NOT NULL",
              name: 'index_contacts_on_phone'
    
    add_index :organizations, :name, 
              unique: true, 
              where: "deleted_at IS NULL",
              name: 'index_organizations_on_name'
    
    add_index :users, :email, 
              unique: true, 
              where: "deleted_at IS NULL",
              name: 'index_users_on_email'
  end

  def down
    # Remove partial indexes
    remove_index :audiences, name: 'index_audiences_on_name'
    remove_index :campaigns, name: 'index_campaigns_on_name'
    remove_index :contacts, name: 'index_contacts_on_email'
    remove_index :contacts, name: 'index_contacts_on_phone'
    remove_index :organizations, name: 'index_organizations_on_name'
    remove_index :users, name: 'index_users_on_email'
    
    # Restore original unique indexes
    add_index :audiences, :name, unique: true, name: 'index_audiences_on_name'
    add_index :campaigns, :name, unique: true, name: 'index_campaigns_on_name'
    add_index :contacts, :email, unique: true, name: 'index_contacts_on_email'
    add_index :contacts, :phone, unique: true, name: 'index_contacts_on_phone'
    add_index :organizations, :name, unique: true, name: 'index_organizations_on_name'
    add_index :users, :email, unique: true, name: 'index_users_on_email'
  end
end
