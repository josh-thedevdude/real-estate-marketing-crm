class AddNotNullToJsonbColumns < ActiveRecord::Migration[8.1]
  def up
    # First, update any existing NULL values to empty JSON objects
    execute "UPDATE audiences SET filters = '{}' WHERE filters IS NULL"
    execute "UPDATE contacts SET preferences = '{}' WHERE preferences IS NULL"
    
    # Then add NOT NULL constraint
    change_column_null :audiences, :filters, false
    change_column_null :contacts, :preferences, false
  end

  def down
    change_column_null :audiences, :filters, true
    change_column_null :contacts, :preferences, true
  end
end
