class UpdateScheduledAtConstraintOnCampaigns < ActiveRecord::Migration[8.1]
  def change
    # Remove old strict constraint
    remove_check_constraint :campaigns, name: "scheduled_at_after_created"

    # Add updated constraint (allow immediate scheduling)
    add_check_constraint :campaigns,
      "scheduled_at IS NULL OR scheduled_at >= created_at",
      name: "scheduled_at_on_or_after_created"
  end
end
