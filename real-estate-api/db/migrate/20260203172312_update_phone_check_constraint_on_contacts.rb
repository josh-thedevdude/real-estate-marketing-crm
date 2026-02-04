class UpdatePhoneCheckConstraintOnContacts < ActiveRecord::Migration[8.1]
  def change
    # Remove old (global / E.164) constraint
    remove_check_constraint :contacts, name: "valid_phone_format"

    # Add new India-only mobile number constraint
    add_check_constraint :contacts,
      "phone IS NULL OR phone ~ '^(\\+91|91)?[6-9][0-9]{9}$'",
      name: "valid_india_mobile_phone"
  end
end
