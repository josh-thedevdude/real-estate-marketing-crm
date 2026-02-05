class AddCustomVariablesToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :custom_variables, :jsonb, default: {}, null: false
  end
end
