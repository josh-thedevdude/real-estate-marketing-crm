module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!, unless: :public_endpoint?
    
    attr_reader :current_user
  end

  # Authenticate user from JWT token in Authorization header
  def authenticate_user!
    token = extract_token_from_header
    
    unless token
      render json: { error: 'Missing authorization token' }, status: :unauthorized
      return
    end

    # Wrap in without_tenant to support super_admin users who don't have an organization
    @current_user = ActsAsTenant.without_tenant do
      User.from_token(token)
    end
    
    unless @current_user
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
      return
    end

    unless @current_user.active?
      render json: { error: 'User account is inactive' }, status: :forbidden
      return
    end

    # Set current tenant for organization scoping
    # Super admins can access all organizations, so we don't set tenant for them
    ActsAsTenant.current_tenant = @current_user.organization unless @current_user.super_admin?
  end

  # Check if current user is a super admin
  def authorize_super_admin!
    unless current_user&.super_admin?
      render json: { error: 'Unauthorized. Super admin access required.' }, status: :forbidden
    end
  end

  # Check if current user is an org admin or super admin
  def authorize_org_admin!
    unless current_user&.org_admin? || current_user&.super_admin?
      render json: { error: 'Unauthorized. Admin access required.' }, status: :forbidden
    end
  end

  # Check if current user belongs to the specified organization
  def authorize_organization!(org_id)
    return if current_user&.super_admin?
    
    unless current_user&.organization_id == org_id.to_i
      render json: { error: 'Unauthorized. Access to this organization is forbidden.' }, status: :forbidden
    end
  end

  private

  # Extract JWT token from Authorization header
  # Expected format: "Bearer <token>"
  def extract_token_from_header
    header = request.headers['Authorization']
    return nil unless header
    
    header.split(' ').last if header.start_with?('Bearer ')
  end

  # Override this method in controllers to skip authentication for specific actions
  def public_endpoint?
    false
  end
end
