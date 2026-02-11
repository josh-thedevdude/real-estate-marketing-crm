module Api
  module V1
    class DashboardController < ApplicationController
      include Authenticatable
      
      before_action :authenticate_user!
      
      # GET /api/v1/dashboard/stats
      def stats
        if current_user.super_admin?
          render json: super_admin_stats
        elsif current_user.org_admin?
          render json: org_admin_stats
        else
          render json: org_user_stats
        end
      end
      
      private
      
      def super_admin_stats
        # Bypass tenant scoping for super admin to count across all organizations
        ActsAsTenant.without_tenant do
          all_users = User.where(deleted_at: nil)
          {
            organizations: Organization.where(deleted_at: nil).count,
            admins: all_users.where(role: ['org_admin', 'super_admin']).count,
            users: all_users.where(role: 'org_user').count,
            total_users: all_users.count
          }
        end
      end
      
      def org_admin_stats
        {
          users: current_user.organization.users.kept.count,
          contacts: Contact.where(created_by: current_user).kept.count,
          audiences: Audience.where(created_by: current_user).kept.count,
          campaigns: Campaign.where(created_by: current_user).kept.count,
          imports: ContactImportLog.where(user: current_user).count
        }
      end
      
      def org_user_stats
        {
          contacts: Contact.where(created_by: current_user).kept.count,
          audiences: Audience.where(created_by: current_user).kept.count,
          campaigns: Campaign.where(created_by: current_user).kept.count
        }
      end
    end
  end
end
