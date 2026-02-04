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

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
