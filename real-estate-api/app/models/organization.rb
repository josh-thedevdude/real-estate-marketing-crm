class Organization < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at
  
  # Callbacks
  before_validation :normalize_name
  
  # Associations
  has_many :users, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :audiences, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  
  # Validations
  validates :name, presence: true, uniqueness: true, length: {minimum: 3, maximum: 50}

  # Scopes
  default_scope { kept }

  private

  # normalize name to lowercase and strip whitespace
  def normalize_name
    self.name = name.strip.downcase if name.present?
  end
end
