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

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
