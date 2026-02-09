module Api
  module V1
    class ContactsController < ApplicationController
      include Authenticatable
      
      before_action :authorize_org_user!
      before_action :set_contact, only: [:show, :update, :destroy]
      before_action :authorize_contact_access!, only: [:show, :update, :destroy]
      
      # GET /api/v1/contacts
      def index
        @contacts = Contact.by_user(current_user.id)
        @contacts = @contacts.search(params[:q]) if params[:q].present?
        @contacts = @contacts.page(params[:page]).per(params[:per_page] || 20)
        
        render json: {
          contacts: @contacts.map { |c| contact_json(c) },
          total: @contacts.total_count,
          page: @contacts.current_page,
          per_page: @contacts.limit_value,
          total_pages: @contacts.total_pages
        }
      end
      
      # GET /api/v1/contacts/:id
      def show
        render json: {
          contact: contact_json(@contact)
        }
      end
      
      # POST /api/v1/contacts
      def create
        @contact = Contact.new(contact_params)
        @contact.created_by = current_user
        @contact.organization = current_user.organization
        
        if @contact.save
          render json: {
            message: 'Contact created successfully',
            contact: contact_json(@contact)
          }, status: :created
        else
          render json: {
            error: 'Failed to create contact',
            errors: @contact.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # PATCH/PUT /api/v1/contacts/:id
      def update
        if @contact.update(contact_params)
          render json: {
            message: 'Contact updated successfully',
            contact: contact_json(@contact)
          }
        else
          render json: {
            error: 'Failed to update contact',
            errors: @contact.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/contacts/:id
      def destroy
        if @contact.discard
          render json: {
            message: 'Contact deleted successfully'
          }
        else
          render json: {
            error: 'Failed to delete contact'
          }, status: :unprocessable_entity
        end
      end
      
      # POST /api/v1/contacts/import
      def import
        file = params[:file]
        
        unless file.present?
          render json: { error: 'File is required' }, status: :unprocessable_entity
          return
        end
        
        unless file.content_type == 'text/csv' || file.original_filename.end_with?('.csv')
          render json: { error: 'File must be a CSV' }, status: :unprocessable_entity
          return
        end
        
        import_log = ContactImportLog.create!(
          user: current_user,
          organization: current_user.organization,
          filename: file.original_filename,
          status: :pending
        )
        
        # Save file temporarily
        temp_file = Tempfile.new(['contact_import', '.csv'])
        temp_file.binmode
        temp_file.write(file.read)
        temp_file.rewind
        
        ContactImportJob.perform_later(import_log.id, temp_file.path)
        
        render json: {
          message: 'Import started',
          job_id: import_log.job_id,
          import_log_id: import_log.id
        }, status: :accepted
      end
      
      private
      
      def set_contact
        @contact = Contact.find_by(id: params[:id])
        
        unless @contact
          render json: { error: 'Contact not found' }, status: :not_found
        end
      end
      
      def authorize_org_user!
        # contacts are organization scoped
        unless current_user.org_admin? || current_user.org_user?
          render json: { error: 'Unauthorized. Organization user access required.' }, status: :forbidden
        end
      end
      
      def authorize_contact_access!
        unless @contact.created_by_id == current_user.id
          render json: { error: 'Unauthorized. You can only access contacts you created.' }, status: :forbidden
        end
      end
      
      def contact_params
        params.require(:contact).permit(
          :first_name,
          :last_name,
          :email,
          :phone,
          preferences: [
            :contact_type,
            :min_budget,
            :max_budget,
            :timeline,
            property_locations: [],
            property_types: []
          ]
        )
      end
      
      def contact_json(contact)
        {
          id: contact.id,
          first_name: contact.first_name,
          last_name: contact.last_name,
          full_name: contact.full_name,
          email: contact.email,
          phone: contact.phone,
          preferences: contact.preferences,
          created_at: contact.created_at,
          updated_at: contact.updated_at
        }
      end
    end
  end
end
