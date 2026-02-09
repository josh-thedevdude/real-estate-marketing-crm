module Api
  module V1
    class AudiencesController < ApplicationController
      include Authenticatable
      
      before_action :authorize_org_user!
      before_action :set_audience, only: [:show, :update, :destroy]
      before_action :authorize_audience_access!, only: [:show, :update, :destroy]
      
      # GET /api/v1/audiences
      def index
        @audiences = Audience.by_user(current_user.id)
        @audiences = @audiences.search(params[:q]) if params[:q].present?
        @audiences = @audiences.page(params[:page]).per(params[:per_page] || 20)
        
        render json: {
          audiences: @audiences.map { |a| audience_json(a) },
          total: @audiences.total_count,
          page: @audiences.current_page,
          per_page: @audiences.limit_value,
          total_pages: @audiences.total_pages
        }
      end
      
      # GET /api/v1/audiences/:id
      def show
        render json: {
          audience: audience_json(@audience, include_contact_count: true)
        }
      end
      
      # POST /api/v1/audiences
      def create
        @audience = Audience.new(audience_params)
        @audience.created_by = current_user
        @audience.organization = current_user.organization
        
        if @audience.save
          render json: {
            message: 'Audience created successfully',
            audience: audience_json(@audience, include_contact_count: true)
          }, status: :created
        else
          render json: {
            error: 'Failed to create audience',
            errors: @audience.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/audiences/:id
      def update
        if @audience.update(audience_params)
          render json: {
            message: 'Audience updated successfully',
            audience: audience_json(@audience, include_contact_count: true)
          }
        else
          render json: {
            error: 'Failed to update audience',
            errors: @audience.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/audiences/:id
      def destroy
        if @audience.discard
          render json: {
            message: 'Audience deleted successfully'
          }
        else
          render json: {
            error: 'Failed to delete audience'
          }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/audiences/preview
      def preview
        filters = params[:filters] || {}
        temp_audience = Audience.new(
          filters: filters,
          organization: current_user.organization,
          name: 'preview',
          created_by: current_user
        )
        
        page = params[:page] || 1
        per_page = params[:per_page] || 20
        
        contacts = AudienceQueryService.new(temp_audience).contacts
                                        .page(page)
                                        .per(per_page)
        
        render json: {
          contact_count: AudienceQueryService.new(temp_audience).count,
          contacts: contacts.map { |c| contact_preview_json(c) },
          page: contacts.current_page,
          per_page: contacts.limit_value,
          total_pages: contacts.total_pages
        }
      end
      
      private
      
      def set_audience
        @audience = Audience.find_by(id: params[:id])
        
        unless @audience
          render json: { error: 'Audience not found' }, status: :not_found
        end
      end
      
      def authorize_org_user!
        unless current_user.org_admin? || current_user.org_user?
          render json: { error: 'Unauthorized. Organization user access required.' }, status: :forbidden
        end
      end
      
      def authorize_audience_access!
        unless @audience.created_by_id == current_user.id
          render json: { error: 'Unauthorized. You can only access audiences you created.' }, status: :forbidden
        end
      end
      
      def audience_params
        params.require(:audience).permit(
          :name,
          :description,
          filters: [
            :contact_type,
            :timeline,
            :min_budget,
            :max_budget,
            property_locations: [],
            property_types: []
          ]
        )
      end
      
      def audience_json(audience, include_contact_count: false)
        json = {
          id: audience.id,
          name: audience.name,
          description: audience.description,
          filters: audience.filters,
          created_at: audience.created_at,
          updated_at: audience.updated_at
        }
        
        json[:contact_count] = audience.contact_count if include_contact_count
        json
      end
      
      def contact_preview_json(contact)
        {
          id: contact.id,
          first_name: contact.first_name,
          last_name: contact.last_name,
          full_name: contact.full_name,
          email: contact.email,
          phone: contact.phone,
          preferences: contact.preferences
        }
      end
    end
  end
end
