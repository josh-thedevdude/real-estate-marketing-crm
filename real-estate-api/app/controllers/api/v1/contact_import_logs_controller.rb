module Api
  module V1
    class ContactImportLogsController < ApplicationController
      include Authenticatable
      
      before_action :authorize_org_user!
      
      # GET /api/v1/contact_import_logs
      def index
        # Both org admins and org users see only their own import logs
        @logs = ContactImportLog.where(user: current_user)
        @logs = @logs.order(created_at: :desc)
                     .page(params[:page])
                     .per(params[:per_page] || 20)
        
        render json: {
          import_logs: @logs.map { |log| import_log_json(log) },
          total: @logs.total_count,
          page: @logs.current_page,
          per_page: @logs.limit_value
        }
      end
      
      # GET /api/v1/contact_import_logs/:id
      def show
        @log = ContactImportLog.find_by(id: params[:id], user: current_user)
        
        unless @log
          render json: { error: 'Import log not found' }, status: :not_found
          return
        end
        
        render json: {
          import_log: import_log_json(@log, include_errors: true)
        }
      end
      
      private
      
      def authorize_org_user!
        unless current_user.org_admin? || current_user.org_user?
          render json: { error: 'Unauthorized. Organization user access required.' }, status: :forbidden
        end
      end
      
      def import_log_json(log, include_errors: false)
        json = {
          id: log.id,
          job_id: log.job_id,
          filename: log.filename,
          status: log.status,
          total_rows: log.total_rows,
          successful_rows: log.successful_rows,
          failed_rows: log.failed_rows,
          success_rate: log.success_rate,
          created_at: log.created_at,
          updated_at: log.updated_at
        }
        
        json[:error_details] = log.error_details if include_errors
        json
      end
    end
  end
end
