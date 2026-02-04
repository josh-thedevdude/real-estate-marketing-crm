module Api
  module V1
    class OrganizationsController < ApplicationController
      include Authenticatable
      
      before_action :authorize_super_admin!
      before_action :set_organization, only: [:show, :update, :destroy]

      # GET /api/v1/organizations
      def index
        # Super admin can see all non-deleted organizations
        # Use .unscoped to also include soft-deleted organizations if needed
        @organizations = ActsAsTenant.without_tenant do
          if params[:include_deleted] == 'true'
            Organization.unscoped.order(created_at: :desc)
          else
            Organization.order(created_at: :desc)
          end
        end

        render json: {
          organizations: @organizations.map { |org| organization_json(org) },
          total: @organizations.count
        }, status: :ok
      end

      # GET /api/v1/organizations/:id
      def show
        render json: {
          organization: organization_json(@organization)
        }, status: :ok
      end

      # POST /api/v1/organizations
      def create
        @organization = Organization.new(organization_params)

        if @organization.save
          render json: {
            message: 'Organization created successfully',
            organization: organization_json(@organization)
          }, status: :created
        else
          render json: {
            error: 'Failed to create organization',
            errors: @organization.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/organizations/:id
      def update
        if @organization.update(organization_params)
          render json: {
            message: 'Organization updated successfully',
            organization: organization_json(@organization)
          }, status: :ok
        else
          render json: {
            error: 'Failed to update organization',
            errors: @organization.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/organizations/:id
      def destroy
        if @organization.discard
          render json: {
            message: 'Organization deleted successfully'
          }, status: :ok
        else
          render json: {
            error: 'Failed to delete organization'
          }, status: :unprocessable_entity
        end
      end

      private

      def set_organization
        @organization = ActsAsTenant.without_tenant do
          Organization.unscoped.find_by(id: params[:id])
        end

        unless @organization
          render json: {
            error: 'Organization not found'
          }, status: :not_found
        end
      end

      def organization_params
        params.require(:organization).permit(:name)
      end

      def organization_json(organization)
        # Wrap counts in without_tenant to avoid NoTenantSet errors
        counts = ActsAsTenant.without_tenant do
          {
            users_count: organization.users.count,
            contacts_count: organization.contacts.count,
            audiences_count: organization.audiences.count,
            campaigns_count: organization.campaigns.count
          }
        end

        {
          id: organization.id,
          name: organization.name,
          deleted_at: organization.deleted_at,
          created_at: organization.created_at,
          updated_at: organization.updated_at
        }.merge(counts)
      end
    end
  end
end
