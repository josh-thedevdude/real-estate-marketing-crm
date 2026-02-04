# == Schema Information
#
# Table name: audiences
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  created_by_id   :integer          not null
#  deleted_at      :datetime
#  description     :text
#  filters         :jsonb            default("{}"), not null
#  name            :string           not null
#  organization_id :integer          not null
#  updated_at      :datetime         not null
#

require "test_helper"

class AudienceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
