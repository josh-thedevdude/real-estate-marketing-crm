class AddEmailTemplateToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_reference :campaigns, :email_template, null: true, foreign_key: true
    
    add_index :campaigns, [:status, :scheduled_at], 
              where: "deleted_at IS NULL AND status = 0",
              name: "index_campaigns_on_status_and_scheduled"
  end
end
