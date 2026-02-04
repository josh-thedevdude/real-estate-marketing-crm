class OptimizeJsonbIndexes < ActiveRecord::Migration[8.1]
  def up
    # Remove existing GIN indexes
    remove_index :audiences, name: 'index_audiences_on_filters'
    remove_index :contacts, name: 'index_contacts_on_preferences'
    
    # Add optimized GIN indexes with jsonb_path_ops
    # Note: jsonb_path_ops only supports @> operator, not all JSONB operations
    # If you need other operators, keep the default gin index
    add_index :audiences, :filters, 
              using: :gin, 
              opclass: :jsonb_path_ops,
              name: 'index_audiences_on_filters'
    
    add_index :contacts, :preferences, 
              using: :gin, 
              opclass: :jsonb_path_ops,
              name: 'index_contacts_on_preferences'
  end

  def down
    remove_index :audiences, name: 'index_audiences_on_filters'
    remove_index :contacts, name: 'index_contacts_on_preferences'
    
    # Restore standard GIN indexes
    add_index :audiences, :filters, using: :gin, name: 'index_audiences_on_filters'
    add_index :contacts, :preferences, using: :gin, name: 'index_contacts_on_preferences'
  end
end
