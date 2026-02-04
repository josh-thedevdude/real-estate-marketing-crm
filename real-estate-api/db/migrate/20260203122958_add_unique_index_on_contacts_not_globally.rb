class AddUniqueIndexOnContactsNotGlobally < ActiveRecord::Migration[8.1]
  def change
    remove_index :contacts, :email
    add_index :contacts,
              [:organization_id, :email],
              unique: true,
              where: "deleted_at IS NULL"
  end
end
