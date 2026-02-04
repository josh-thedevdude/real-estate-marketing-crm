# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  created_by_id          :integer
#  deleted_at             :datetime
#  email                  :string           not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_token       :string
#  invited_by_id          :integer
#  jti                    :string           not null
#  organization_id        :integer
#  password_digest        :string
#  role                   :integer          default(2), not null
#  status                 :integer          default(0), not null
#  updated_at             :datetime         not null
#

class User < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at # allows for soft delete

  # Multi-tenancy - optional for super_admin users
  acts_as_tenant :organization, optional: true

  # Password encryption
  has_secure_password validations: false

  # Enums
  enum :role, { super_admin: 0, org_admin: 1, org_user: 2 }, default: :org_user
  enum :status, { inactive: 0, active: 1 }, default: :inactive

  # Associations
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :invited_by, class_name: 'User', optional: true
  
  has_many :created_users, class_name: 'User', foreign_key: 'created_by_id', dependent: :delete_all
  has_many :invited_users, class_name: 'User', foreign_key: 'invited_by_id', dependent: :delete_all
  has_many :created_contacts, class_name: 'Contact', foreign_key: 'created_by_id', dependent: :delete_all
  has_many :created_audiences, class_name: 'Audience', foreign_key: 'created_by_id', dependent: :delete_all
  has_many :created_campaigns, class_name: 'Campaign', foreign_key: 'created_by_id', dependent: :delete_all

  # Validations
  validates :email, presence: true, 
                    uniqueness: {
                      scope: [:organization_id, :deleted_at],
                      conditions: -> { where(deleted_at: nil) }
                    },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  # validates :role, presence: true
  # validates :status, presence: true
  validates :jti, presence: true, uniqueness: true
  # Password is only validated when it's being set (not on regular updates)
  validates :password, length: { minimum: 8, maximum: 15 }, if: -> { password.present? }
  
  # Organization is required for org_admin and org_user
  validates :organization, presence: true, if: -> { org_admin? || org_user? }

  # Callbacks
  before_validation :generate_jti, on: :create
  before_create :generate_invitation_token, unless: :super_admin?
  before_create :set_invitation_created_at, unless: :super_admin?
  before_save :downcase_email

  # Scopes
  default_scope { kept }
  scope :active_users, -> { where(status: :active) }
  scope :pending_invitations, -> { where(status: :inactive) }

  # Instance Methods

  # Generate a unique JWT identifier
  def generate_jti
    self.jti ||= SecureRandom.uuid
  end

  # Generate a secure invitation token
  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64(32)
  end

  # Set invitation created timestamp
  def set_invitation_created_at
    self.invitation_created_at = Time.current
  end

  # Downcase email before saving
  def downcase_email
    self.email = email.downcase if email.present?
  end

  # Accept invitation and set password
  def accept_invitation!(password)
    self.password = password
    self.status = :active
    self.invitation_accepted_at = Time.current
    save!
  end

  # Generate JWT token for authentication
  def generate_jwt(expiration = 24.hours.from_now)
    payload = {
      user_id: id,
      jti: jti,
      exp: expiration.to_i
    }
    JsonWebToken.encode(payload)
  end

  # Revoke the current JWT token by generating a new JTI
  def revoke_token!
    new_jti = SecureRandom.uuid
    update_column(:jti, new_jti)
  end

  # Check if user can create organizations
  def can_create_organization?
    super_admin?
  end

  # Check if user can create users with specific role for an organization
  def can_create_user?(target_role, target_organization_id)
    return false unless active?
    
    if super_admin?
      # Super admin can create any user for any organization
      true
    elsif org_admin?
      # Org admin can only create users for their own organization
      # and cannot create super_admins
      return false if target_role.to_s == 'super_admin'
      return false if target_organization_id != organization_id
      true
    else
      # Org users cannot create other users
      false
    end
  end

  # Check if user can manage (update/delete) another user
  def can_manage_user?(target_user)
    return false unless active?
    return false if target_user.super_admin? # Cannot manage super admins
    
    if super_admin?
      true
    elsif org_admin?
      # Can only manage users in their organization
      target_user.organization_id == organization_id && !target_user.super_admin?
    else
      false
    end
  end

  # Class Methods
  
  # Decode JWT and find user
  def self.from_token(token)
    decoded = JsonWebToken.decode(token)
    return nil unless decoded
    
    user = find_by(id: decoded[:user_id])
    # Verify JTI matches (for token revocation)
    return nil unless user && user.jti == decoded[:jti]
    
    user
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
