class CampaignSchedulerJob < ApplicationJob
  queue_as :default
  
  def perform
    Rails.logger.info("Campaign Scheduler: Starting...")
    
    total_campaigns = 0
    
    # Iterate through all organizations
    ActsAsTenant.without_tenant do
      Organization.find_each do |org|
        ActsAsTenant.with_tenant(org) do
          Rails.logger.info("Campaign Scheduler: Checking campaigns for organization ##{org.id} - #{org.name}")
          
          # Find campaigns due for execution
          due_campaigns = Campaign.due_for_execution
          
          Rails.logger.info("Campaign Scheduler: Found #{due_campaigns.count} due campaigns")
          
          due_campaigns.each do |campaign|
            Rails.logger.info("Campaign Scheduler: Preparing campaign ##{campaign.id} - #{campaign.name}")
            
            if CampaignExecutionService.new(campaign).prepare!
              Rails.logger.info("Campaign Scheduler: Successfully started campaign ##{campaign.id}")
              total_campaigns += 1
              
              # For recurring campaigns, schedule next execution
              if campaign.recurring?
                schedule_next_execution(campaign)
              end
            else
              Rails.logger.error("Campaign Scheduler: Failed to start campaign ##{campaign.id}")
            end
          end
        end
      end
    end
    
    Rails.logger.info("Campaign Scheduler: Completed. Executed #{total_campaigns} campaigns")
  end
  
  private
  
  def schedule_next_execution(campaign)
    # Calculate next execution time (e.g., +1 week)
    next_scheduled_at = campaign.scheduled_at + 1.week
    
    # Create new campaign for next execution
    new_campaign = campaign.dup
    new_campaign.scheduled_at = next_scheduled_at
    new_campaign.status = :created
    
    if new_campaign.save
      # Copy audiences
      new_campaign.audiences << campaign.audiences
      
      Rails.logger.info("Campaign Scheduler: Scheduled next execution of campaign '#{campaign.name}' for #{next_scheduled_at}")
    else
      Rails.logger.error("Campaign Scheduler: Failed to schedule next execution: #{new_campaign.errors.full_messages}")
    end
  end
end
