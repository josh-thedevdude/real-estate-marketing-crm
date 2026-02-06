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
              if campaign.recurring? && campaign.should_continue_recurring?
                schedule_next_execution(campaign)
              elsif campaign.recurring?
                Rails.logger.info("Campaign Scheduler: Campaign ##{campaign.id} will not recur (end date or max occurrences reached)")
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
    # Calculate next execution time based on recurrence interval
    next_scheduled_at = campaign.next_scheduled_time
    
    return unless next_scheduled_at
    
    # Create new campaign for next execution
    new_campaign = campaign.dup
    new_campaign.scheduled_at = next_scheduled_at
    new_campaign.status = :created
    new_campaign.occurrence_count = campaign.occurrence_count # Will be incremented on execution
    
    # Explicitly copy recurring fields (dup doesn't always copy enum values)
    new_campaign.recurrence_interval = campaign.recurrence_interval
    new_campaign.recurrence_end_date = campaign.recurrence_end_date
    new_campaign.max_occurrences = campaign.max_occurrences
    
    if new_campaign.save
      # Copy audiences
      new_campaign.audiences << campaign.audiences
      
      Rails.logger.info("Campaign Scheduler: Scheduled next execution of campaign '#{campaign.name}' for #{next_scheduled_at} (#{campaign.recurrence_interval})")
    else
      Rails.logger.error("Campaign Scheduler: Failed to schedule next execution: #{new_campaign.errors.full_messages.join(', ')}")
    end
  end
end
