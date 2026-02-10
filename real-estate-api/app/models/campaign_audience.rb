class CampaignAudience < ApplicationRecord
  belongs_to :campaign
  belongs_to :audience

  validate :same_organization

  private

  def same_organization
    return if campaign.organization_id == audience.organization_id
    errors.add(:base, "Campaign and Audience must belong to the same organization")
  end
end
