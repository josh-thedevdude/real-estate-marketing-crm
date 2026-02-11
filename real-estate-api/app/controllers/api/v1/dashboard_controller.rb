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
          contacts: current_user.organization.contacts.kept.count,
          audiences: current_user.organization.audiences.kept.count,
          campaigns: current_user.organization.campaigns.kept.count,
          imports: current_user.organization.contact_import_logs.count
        }
      end
      
      def org_user_stats
        {
          contacts: current_user.organization.contacts.kept.count,
          audiences: current_user.organization.audiences.kept.count,
          campaigns: current_user.organization.campaigns.kept.count
        }
      end
    end
  end
end
