class AllowNullNamesOnContacts < ActiveRecord::Migration[8.1]
  def change
    change_column_null :contacts, :first_name, true
    change_column_null :contacts, :last_name, true
  end
end
