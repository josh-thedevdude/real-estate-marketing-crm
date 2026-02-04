class AddUniqueIndexToUsersInvitationToken < ActiveRecord::Migration[8.1]
  def change
    add_index :users,
              :invitation_token,
              unique: true,
              where: "invitation_token IS NOT NULL",
              name: "index_users_on_unique_invitation_token"
  end
end
