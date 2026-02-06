module Api
  module V1
    class AuthenticationController < ApplicationController
      include Authenticatable
      
      # POST /api/v1/auth/login
      def login
        # Get email and password from params (support both direct and nested formats)
        email = params[:email] || params.dig(:authentication, :email)
        password = params[:password] || params.dig(:authentication, :password)
        
        # Strip whitespace
        email = email&.strip
        password = password&.strip
        
        # Find user by email (without tenant for super_admin, with tenant for org users)
        user = find_user_by_email(email)

        unless user
          render json: {
            error: 'Invalid email or password'
          }, status: :unauthorized
          return
        end
        
        # Verify password
        unless user.authenticate(password)
          render json: {
            error: 'Invalid email or password'
          }, status: :unauthorized
          return
        end

        # Check if user is active
        unless user.active?
          render json: {
            error: 'Account is inactive. Please contact your administrator.'
          }, status: :forbidden
          return
        end

        # Generate JWT token
        token = user.generate_jwt

        render json: {
          message: 'Login successful',
          token: token,
          user: user_json(user)
        }, status: :ok
      end

      # POST /api/v1/auth/logout
      def logout
        # Require authentication for logout
        authenticate_user!

        # Revoke the current token
        current_user.revoke_token!

        render json: {
          message: 'Logout successful'
        }, status: :ok
      end

      # GET /api/v1/auth/me
      def me
        # Require authentication
        authenticate_user!

        render json: {
          user: user_json(current_user)
        }, status: :ok
      end

      private

      def find_user_by_email(email)
        return nil if email.blank?

        # Try to find user without tenant first (for super_admin)
        # Only find users with a password_digest set
        user = ActsAsTenant.without_tenant do
          User.unscoped.where(email: email.downcase.strip).where.not(password_digest: [nil, '']).order(id: :desc).first
        end

        user
      end

      def user_json(user)
        {
          id: user.id,
          email: user.email,
          role: user.role,
          status: user.status,
          organization_id: user.organization_id,
          organization_name: user.organization&.name,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end

      # Override from Authenticatable concern to make endpoints public by default
      def public_endpoint?
        action_name == 'login'
      end
    end
  end
end
