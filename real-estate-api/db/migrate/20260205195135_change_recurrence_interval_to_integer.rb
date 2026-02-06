class ChangeRecurrenceIntervalToInteger < ActiveRecord::Migration[8.1]
  def up
    # Change column type from string to integer
    change_column :campaigns, :recurrence_interval, :integer, using: 'recurrence_interval::integer'
  end
  
  def down
    # Revert back to string
    change_column :campaigns, :recurrence_interval, :string
  end
end
