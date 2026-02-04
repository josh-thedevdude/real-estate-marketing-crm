# == Schema Information
#
# Table name: campaigns
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  created_by_id   :integer          not null
#  deleted_at      :datetime
#  description     :text
#  name            :string           not null
#  organization_id :integer          not null
#  scheduled_at    :datetime
#  scheduled_type  :integer          default(0), not null
#  status          :integer          default(0), not null
#  updated_at      :datetime         not null
#

require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
