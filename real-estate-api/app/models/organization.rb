# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  deleted_at :datetime
#  name       :string           not null
#  updated_at :datetime         not null
#

class Organization < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at # allows for soft delete
  
  before_validation :normalize_name
  
  # Associations
  has_many :users, dependent: :delete_all       # delete all users when organization is deleted
  has_many :contacts, dependent: :delete_all    # delete all contacts when organization is deleted
  has_many :audiences, dependent: :delete_all   # delete all audiences when organization is deleted
  has_many :campaigns, dependent: :delete_all   # delete all campaigns when organization is deleted
  
  # Validations
  validates :name, presence: true, uniqueness: true, length: {minimum: 3, maximum: 50} # name must be unique

  # Scopes
  default_scope { kept } # default scope to show only non-deleted records

  private

  # normalize name to lowercase and strip whitespace
  def normalize_name
    self.name = name.strip.downcase if name.present?
  end
end
