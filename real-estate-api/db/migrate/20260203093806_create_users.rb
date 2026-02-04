class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      # Foreign keys - all nullable
      t.references :org, null: true, foreign_key: { to_table: :organizations, on_delete: :nullify }
      t.references :created_by, null: true, foreign_key: { to_table: :users, on_delete: :nullify }
      t.references :invited_by, null: true, foreign_key: { to_table: :users, on_delete: :nullify }
      
      # Authentication fields
      t.string :email, null: false
      t.string :encrypted_password
      
      # Enums (stored as integers)
      t.integer :role, null: false, default: 2  # default to org_user
      t.integer :status, null: false, default: 0  # default to inactive
      
      # Invitation fields
      t.string :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_accepted_at
      
      # JWT identifier
      t.string :jti, null: false
      
      # Soft delete
      t.datetime :deleted_at

      t.timestamps
    end
    
    # Indexes
    add_index :users, :email, unique: true
    add_index :users, :jti, unique: true
    add_index :users, :invitation_token
    add_index :users, :deleted_at
  end
end
