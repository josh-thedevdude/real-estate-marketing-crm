class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.datetime :deleted_at

      t.timestamps
    end
    
    add_index :organizations, :name, unique: true
    add_index :organizations, :deleted_at
  end
end
