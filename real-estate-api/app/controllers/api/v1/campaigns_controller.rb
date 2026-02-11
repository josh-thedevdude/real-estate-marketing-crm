module Api
  module V1
    class CampaignsController < ApplicationController
      include Authenticatable
      
      before_action :authorize_org_user!
      before_action :set_campaign, only: [:show, :update, :destroy, :execute, :monitor, :emails]
      before_action :authorize_campaign_access!, only: [:show, :update, :destroy, :execute, :monitor, :emails]
      before_action :check_can_update!, only: [:update]
      
      # GET /api/v1/campaigns/templates
      def templates
        @templates = EmailTemplate.where(organization: current_user.organization)
        
        render json: {
          templates: @templates.map { |t|
            {
              id: t.id,
              name: t.name,
              subject: t.subject,
              body: t.body,
              created_at: t.created_at,
              updated_at: t.updated_at
            }
          }
        }
      end
      
      # GET /api/v1/campaigns
      def index
        @campaigns = Campaign.by_user(current_user.id)
        @campaigns = @campaigns.with_discarded if params[:include_deleted] == 'true'
        @campaigns = @campaigns.search(params[:q]) if params[:q].present?
        @campaigns = @campaigns.by_status(params[:status]) if params[:status].present?
        @campaigns = @campaigns.page(params[:page]).per(params[:per_page] || 20)
        
        render json: {
          campaigns: @campaigns.map { |c| campaign_json(c) },
          total: @campaigns.total_count,
          page: @campaigns.current_page,
          per_page: @campaigns.limit_value
        }
      end
      
      # GET /api/v1/campaigns/:id
      def show
        render json: {
          campaign: campaign_json(@campaign, include_stats: true)
        }
      end
      
      # POST /api/v1/campaigns
      def create
        @campaign = Campaign.new(campaign_params)
        @campaign.created_by = current_user
        @campaign.organization = current_user.organization
        
        if @campaign.save
          # Associate audiences with validation
          audience_ids = permitted_audience_ids
          if audience_ids.present?
            audiences = Audience.where(
              id: audience_ids,
              organization: current_user.organization,
              created_by: current_user
            )
            
            # Check if all provided audience IDs were found
            if audiences.count != audience_ids.count
              invalid_ids = audience_ids - audiences.pluck(:id)
              @campaign.destroy
              render json: {
                error: 'Invalid audience IDs',
                message: "Audience IDs #{invalid_ids.join(', ')} do not exist or do not belong to you"
              }, status: :unprocessable_entity
              return
            end
            
            @campaign.audiences << audiences
          end
          
          render json: {
            message: 'Campaign created successfully',
            campaign: campaign_json(@campaign)
          }, status: :created
        else
          render json: {
            error: 'Failed to create campaign',
            errors: @campaign.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/campaigns/:id
      def update
        if @campaign.update(campaign_params)
          # Update audiences if provided with validation
          audience_ids = permitted_audience_ids
          if audience_ids.present?
            audiences = Audience.where(
              id: audience_ids,
              organization: current_user.organization,
              created_by: current_user
            )
            
            # Check if all provided audience IDs were found
            if audiences.count != audience_ids.count
              invalid_ids = audience_ids - audiences.pluck(:id)
              render json: {
                error: 'Invalid audience IDs',
                message: "Audience IDs #{invalid_ids.join(', ')} do not exist or do not belong to you"
              }, status: :unprocessable_entity
              return
            end
            
            @campaign.audiences = audiences
          end
          
          render json: {
            message: 'Campaign updated successfully',
            campaign: campaign_json(@campaign)
          }
        else
          render json: {
            error: 'Failed to update campaign',
            errors: @campaign.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/campaigns/:id
      def destroy
        if @campaign.discard
          render json: {
            message: 'Campaign deleted successfully'
          }
        else
          render json: {
            error: 'Failed to delete campaign'
          }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/campaigns/:id/execute
      def execute
        unless @campaign.can_execute?
          render json: {
            error: 'Campaign cannot be executed',
            reasons: execution_errors
          }, status: :unprocessable_entity
          return
        end
        
        if CampaignExecutionService.new(@campaign).prepare!
          render json: {
            message: 'Campaign execution started',
            campaign: campaign_json(@campaign, include_stats: true)
          }
        else
          render json: {
            error: 'Failed to start campaign execution'
          }, status: :unprocessable_entity
        end
      end
      
      # GET /api/v1/campaigns/:id/monitor
      def monitor
        stats = @campaign.campaign_statistic || @campaign.build_campaign_statistic
        
        render json: {
          campaign_id: @campaign.id,
          status: @campaign.status,
          total_emails: stats.total_emails || 0,
          sent_emails: stats.emails_sent || 0,
          failed_emails: stats.emails_failed || 0,
          pending_emails: (stats.total_emails || 0) - (stats.emails_sent || 0) - (stats.emails_failed || 0),
          progress: stats.total_emails.to_i > 0 ? ((stats.emails_sent.to_f / stats.total_emails) * 100).round(2) : 0
        }
      end
      
      # GET /api/v1/campaigns/:id/emails
      def emails
        @emails = @campaign.campaign_emails
        @emails = @emails.by_status(params[:status]) if params[:status].present?
        @emails = @emails.page(params[:page]).per(params[:per_page] || 20)
        
        render json: {
          campaign_emails: @emails.map { |e| email_json(e) },
          total: @emails.total_count,
          page: @emails.current_page,
          per_page: @emails.limit_value
        }
      end
      
      # POST /api/v1/campaigns/preview_contacts
      def preview_contacts
        unless params[:audience_ids].present?
          render json: { error: 'audience_ids required' }, status: :unprocessable_entity
          return
        end
        
        contacts = CampaignContactsService.preview(
          params[:audience_ids],
          current_user.organization
        )
        
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i
        
        paginated_contacts = Kaminari.paginate_array(contacts).page(page).per(per_page)
        
        render json: {
          total_contacts: contacts.count,
          contacts: paginated_contacts.map { |c| contact_preview_json(c) },
          page: page,
          per_page: per_page,
          total_pages: paginated_contacts.total_pages
        }
      end
      
      private
      
      def set_campaign
        @campaign = Campaign.find_by(id: params[:id])
        
        unless @campaign
          render json: { error: 'Campaign not found' }, status: :not_found
        end
      end
      
      def authorize_org_user!
        unless current_user.super_admin? || current_user.org_admin? || current_user.org_user?
          render json: { error: 'Unauthorized. Organization user access required.' }, status: :forbidden
        end
      end
      
      def authorize_campaign_access!
        unless current_user.super_admin? || @campaign.created_by_id == current_user.id
          render json: { error: 'Unauthorized. You can only access campaigns you created.' }, status: :forbidden
        end
      end
      
      def check_can_update!
        unless @campaign.can_update?
          render json: { error: 'Cannot update campaign that is not in created status' }, status: :unprocessable_entity
        end
      end
      
      def execution_errors
        errors = []
        errors << 'Campaign must be in created status' unless @campaign.created?
        errors << 'Campaign must have at least one audience or smart filters configured' unless @campaign.has_target_contacts?
        errors << 'Campaign must have an email template or subject and body' unless @campaign.email_template.present? || (@campaign.subject.present? && @campaign.body.present?)
        errors
      end
      
      def campaign_params
        params.require(:campaign).permit(
          :name,
          :description,
          :subject,
          :body,
          :email_template_id,
          :scheduled_type,
          :scheduled_at,
          :recurrence_interval,
          :recurrence_end_date,
          :max_occurrences,
          custom_variables: {},
          filters: [
            :contact_type,
            property_locations: [],
            property_types: [],
            timelines: []
          ]
        )
      end
      
      def permitted_audience_ids
        params.permit(audience_ids: [])[:audience_ids] || []
      end
      
      def campaign_json(campaign, include_stats: false)
        json = {
          id: campaign.id,
          name: campaign.name,
          description: campaign.description,
          subject: campaign.subject,
          body: campaign.body,
          status: campaign.status,
          scheduled_type: campaign.scheduled_type,
          scheduled_at: campaign.scheduled_at,
          email_template_id: campaign.email_template_id,
          filters: campaign.filters || {},
          audience_ids: campaign.audiences.pluck(:id),
          audiences: campaign.audiences.map { |a| { id: a.id, name: a.name } },
          created_at: campaign.created_at,
          updated_at: campaign.updated_at,
          deleted_at: campaign.deleted_at
        }
        
        # Add recurring campaign fields if applicable
        if campaign.recurring?
          json[:recurrence_interval] = campaign.recurrence_interval
          json[:recurrence_end_date] = campaign.recurrence_end_date
          json[:max_occurrences] = campaign.max_occurrences
          json[:occurrence_count] = campaign.occurrence_count
        end
        
        if include_stats && campaign.campaign_statistic
          json[:statistics] = {
            total_contacts: campaign.total_contacts,
            emails_sent: campaign.emails_sent,
            emails_failed: campaign.campaign_statistic.emails_failed,
            success_rate: campaign.success_rate,
            last_sent_at: campaign.campaign_statistic.last_sent_at
          }
        end
        
        json
      end
      
      def email_json(email)
        {
          id: email.id,
          contact_id: email.contact_id,
          contact_name: email.contact.full_name,
          email: email.email,
          subject: email.subject,
          status: email.status,
          sent_at: email.sent_at,
          error_message: email.error_message,
          created_at: email.created_at
        }
      end
      
      def contact_preview_json(contact)
        {
          id: contact.id,
          first_name: contact.first_name,
          last_name: contact.last_name,
          full_name: contact.full_name,
          email: contact.email,
          phone: contact.phone
        }
      end
    end
  end
end
