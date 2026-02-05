# Campaign Scheduler Setup
#
# This initializer sets up a recurring job to check for due campaigns
# and execute them automatically.
#
# For development, you can manually trigger the scheduler:
# CampaignSchedulerJob.perform_now
#
# For production, use a cron job or scheduler service like:
# - Sidekiq-Cron
# - Whenever gem
# - Heroku Scheduler
# - AWS EventBridge
#
# Example cron schedule: */5 * * * * (every 5 minutes)

Rails.application.config.after_initialize do
  # In development, you can uncomment this to run the scheduler every 5 minutes
  # Note: This uses Rails' built-in async adapter, not recommended for production
  
  if Rails.env.development?
    Thread.new do
      loop do
        sleep 2.minutes
        CampaignSchedulerJob.perform_later
      end
    end
  end
  
  Rails.logger.info("Campaign Scheduler: Initialized")
  Rails.logger.info("Campaign Scheduler: To manually run, execute: CampaignSchedulerJob.perform_now")
end
