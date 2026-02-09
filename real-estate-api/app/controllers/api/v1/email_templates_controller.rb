require 'ostruct'

module Api
  module V1
    class EmailTemplatesController < ApplicationController
      include Authenticatable
      
      before_action :authorize_org_user!
      before_action :set_email_template, only: [:show, :update, :destroy]
      before_action :authorize_template_access!, only: [:show, :update, :destroy]
      
      # GET /api/v1/email_templates
      def index
        @templates = EmailTemplate.by_user(current_user.id)
        @templates = @templates.search(params[:q]) if params[:q].present?
        @templates = @templates.page(params[:page]).per(params[:per_page] || 20)
        
        render json: {
          email_templates: @templates.map { |t| template_json(t) },
          total: @templates.total_count,
          page: @templates.current_page,
          per_page: @templates.limit_value,
          total_pages: @templates.total_pages
        }
      end
      
      # GET /api/v1/email_templates/:id
      def show
        render json: {
          email_template: template_json(@template)
        }
      end
      
      # POST /api/v1/email_templates
      def create
        @template = EmailTemplate.new(template_params)
        @template.created_by = current_user
        @template.organization = current_user.organization
        
        if @template.save
          render json: {
            message: 'Email template created successfully',
            email_template: template_json(@template)
          }, status: :created
        else
          render json: {
            error: 'Failed to create email template',
            errors: @template.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/email_templates/:id
      def update
        if @template.update(template_params)
          render json: {
            message: 'Email template updated successfully',
            email_template: template_json(@template)
          }
        else
          render json: {
            error: 'Failed to update email template',
            errors: @template.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/email_templates/:id
      def destroy
        if @template.discard
          render json: {
            message: 'Email template deleted successfully'
          }
        else
          render json: {
            error: 'Failed to delete email template'
          }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/email_templates/preview
      def preview
        # Create temporary template for preview
        temp_template = EmailTemplate.new(
          subject: params[:subject],
          body: params[:body],
          organization: current_user.organization,
          created_by: current_user,
          name: 'preview'
        )
        
        # Sample contact data
        sample_contact = OpenStruct.new(
          first_name: params[:first_name] || 'John',
          last_name: params[:last_name] || 'Doe',
          full_name: "#{params[:first_name] || 'John'} #{params[:last_name] || 'Doe'}",
          email: params[:email] || 'john.doe@example.com',
          phone: params[:phone] || '9876543210'
        )
        
        # Convert custom_vars to hash if present
        custom_vars = params[:custom_vars].present? ? params[:custom_vars].to_unsafe_h : {}
        
        rendered = temp_template.render_for_contact(sample_contact, custom_vars)
        
        render json: {
          preview: rendered,
          sample_data: {
            first_name: sample_contact.first_name,
            last_name: sample_contact.last_name,
            full_name: sample_contact.full_name,
            email: sample_contact.email,
            phone: sample_contact.phone
          }
        }
      end
      
      private
      
      def set_email_template
        @template = EmailTemplate.find_by(id: params[:id])
        
        unless @template
          render json: { error: 'Email template not found' }, status: :not_found
        end
      end
      
      def authorize_org_user!
        unless current_user.org_admin? || current_user.org_user?
          render json: { error: 'Unauthorized. Organization user access required.' }, status: :forbidden
        end
      end
      
      def authorize_template_access!
        unless @template.created_by_id == current_user.id
          render json: { error: 'Unauthorized. You can only access templates you created.' }, status: :forbidden
        end
      end
      
      def template_params
        params.require(:email_template).permit(
          :name,
          :subject,
          :body,
          variables: {}
        )
      end
      
      def template_json(template)
        {
          id: template.id,
          name: template.name,
          subject: template.subject,
          body: template.body,
          variables: template.variables,
          created_at: template.created_at,
          updated_at: template.updated_at
        }
      end
    end
  end
end
