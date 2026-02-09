module Api
  module V1
    class UsersController < ApplicationController
      include Authenticatable
      
      before_action :set_user, only: [:show, :update, :destroy]
      before_action :authorize_user_access!, only: [:show, :update, :destroy]
      before_action :authorize_user_management!, only: [:index, :create]

      # GET /api/v1/users
      def index
        @users = fetch_users_by_role
        
        # Pagination
        @users = Kaminari.paginate_array(@users).page(params[:page]).per(params[:per_page] || 20)

        render json: {
          users: @users.map { |user| user_json(user) },
          total: @users.total_count,
          page: @users.current_page,
          per_page: @users.limit_value,
          total_pages: @users.total_pages
        }, status: :ok
      end

      # GET /api/v1/users/:id
      def show
        render json: {
          user: user_json(@user)
        }, status: :ok
      end

      # POST /api/v1/users
      def create
        # Validate role and organization
        unless can_create_user_with_role?
          render json: {
            error: 'Unauthorized to create user with this role'
          }, status: :forbidden
          return
        end

        # Wrap in without_tenant to avoid NoTenantSet error
        @user = ActsAsTenant.without_tenant do
          user = User.new(user_create_params)
          user.created_by = current_user
          user.invited_by = current_user
          
          if user.save
            # Send invitation email
            UserMailer.invitation_email(user).deliver_later
            user
          else
            user
          end
        end

        if @user.persisted?
          render json: {
            message: 'User invited successfully. Invitation email sent.',
            user: user_json(@user)
          }, status: :created
        else
          render json: {
            error: 'Failed to create user',
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        # no user can update their role to super_admin
        if params[:user][:role].present?
          if params[:user][:role] == "super_admin"
            render json: {
              error: 'Unauthorized to update user role'
            }, status: :forbidden
            return
          end
        end 
          
        if @user.update(user_update_params)
          render json: {
            message: 'User updated successfully',
            user: user_json(@user)
          }, status: :ok
        else
          render json: {
            error: 'Failed to update user',
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        if @user.discard
          render json: {
            message: 'User deleted successfully'
          }, status: :ok
        else
          render json: {
            error: 'Failed to delete user'
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/users/accept_invitation
      def accept_invitation
        token = params[:invitation_token]
        password = params[:password]

        unless token.present? && password.present?
          render json: {
            error: 'Invitation token and password are required'
          }, status: :unprocessable_entity
          return
        end

        @user = ActsAsTenant.without_tenant do
          User.find_by(invitation_token: token)
        end

        unless @user
          render json: {
            error: 'Invalid invitation token'
          }, status: :not_found
          return
        end

        if @user.invitation_accepted_at.present?
          render json: {
            error: 'Invitation has already been accepted'
          }, status: :unprocessable_entity
          return
        end

        # Validate password length before accepting
        if password.length < 8
          render json: {
            error: 'Password is too short (minimum is 8 characters)'
          }, status: :unprocessable_entity
          return
        end

        if password.length > 15
          render json: {
            error: 'Password is too long (maximum is 15 characters)'
          }, status: :unprocessable_entity
          return
        end

        if @user.accept_invitation!(password)
          # Generate JWT token for immediate login
          jwt_token = @user.generate_jwt

          render json: {
            message: 'Invitation accepted successfully',
            token: jwt_token,
            user: user_json(@user)
          }, status: :ok
        else
          render json: {
            error: 'Failed to accept invitation',
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = ActsAsTenant.without_tenant do
          if current_user.super_admin?
            User.find_by(id: params[:id])
          else
            User.find_by(id: params[:id], organization_id: current_user.organization_id)
          end
        end

        unless @user
          render json: {
            error: 'User not found'
          }, status: :not_found
        end
      end

      def fetch_users_by_role
        ActsAsTenant.without_tenant do
          # Super admin can see users they created
          if current_user.super_admin?
            User.where(created_by_id: current_user.id).order(created_at: :desc)
          # Org admin can see users they created in their organization
          elsif current_user.org_admin?
            User.where(
              created_by_id: current_user.id,
              organization_id: current_user.organization_id
            ).order(created_at: :desc)
          else
            # Org users cannot list other users
            # User.where(id: current_user.id)
            []
          end
        end
      end

      def authorize_user_access!
        # user can access himself
        return if @user.id == current_user.id
        
        # Super admin can access users they created
        return if current_user.super_admin? && @user.created_by_id == current_user.id
        
        # Org admin can access users they created in their organization
        return if current_user.org_admin? && 
                  @user.created_by_id == current_user.id && 
                  @user.organization_id == current_user.organization_id

        render json: {
          error: 'Unauthorized to access this user'
        }, status: :forbidden
      end

      def authorize_user_management!
        # org_users cannot create users
        unless current_user.super_admin? || current_user.org_admin?
          render json: {
            error: 'Unauthorized. Admin access required.'
          }, status: :forbidden
        end
      end

      def can_create_user_with_role?
        target_role = params.dig(:user, :role)&.to_sym
        target_org_id = params.dig(:user, :organization_id)

        current_user.can_create_user?(target_role, target_org_id)
      end

      def user_create_params
        params.require(:user).permit(:email, :role, :organization_id)
      end

      def user_update_params
        # current user can only change his email
        if @user.id == current_user.id 
          params.require(:user).permit(:email)
        # super admin and org admin can update role of the users they have created
        elsif current_user.super_admin? || current_user.org_admin?
          params.require(:user).permit(:role)
        end
      end

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          status: user.status,
          organization_id: user.organization_id,
          organization_name: user.organization&.name,
          invitation_token: user.invitation_token,
          invitation_created_at: user.invitation_created_at,
          invitation_accepted_at: user.invitation_accepted_at,
          created_at: user.created_at,
          updated_at: user.updated_at,
          deleted_at: user.deleted_at
        }
      end

      # Override from Authenticatable to make accept_invitation public
      def public_endpoint?
        action_name == 'accept_invitation'
      end
    end
  end
end
