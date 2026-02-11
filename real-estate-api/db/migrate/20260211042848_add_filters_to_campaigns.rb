class AddFiltersToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :filters, :jsonb, default: {}, null: false
    add_index :campaigns, :filters, using: :gin
  end
end
