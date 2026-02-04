# == Schema Information
#
# Table name: contacts
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  created_by_id   :integer          not null
#  deleted_at      :datetime
#  email           :string           not null
#  first_name      :string
#  last_name       :string
#  organization_id :integer          not null
#  phone           :string
#  preferences     :jsonb            default("{}"), not null
#  updated_at      :datetime         not null
#

require "test_helper"

class ContactTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
