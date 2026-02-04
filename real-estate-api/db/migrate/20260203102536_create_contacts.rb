class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      # Foreign keys - created_by is NOT NULL
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      
      # Contact details
      t.string :first_name, null: true
      t.string :last_name, null: true
      t.string :email, null: false
      t.string :phone, null: true
      
      # JSONB preferences
      t.jsonb :preferences, default: {}
      
      # Soft delete
      t.datetime :deleted_at

      t.timestamps
    end
    
    # Indexes
    add_index :contacts, :email, unique: true
    add_index :contacts, :phone, unique: true
    add_index :contacts, :deleted_at
    add_index :contacts, :preferences, using: :gin
  end
end
