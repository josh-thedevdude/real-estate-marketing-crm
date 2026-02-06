class AudienceContact < ApplicationRecord
  belongs_to :audience
  belongs_to :contact
  
  validates :audience_id, uniqueness: { scope: :contact_id }
end
