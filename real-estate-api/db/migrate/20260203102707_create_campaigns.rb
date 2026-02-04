class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      # Foreign keys - created_by is NOT NULL
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      
      # Campaign details
      t.integer :audience_ids, array: true, default: []
      t.string :name, null: false
      t.text :description
      
      # Scheduling
      t.integer :scheduled_type, null: false, default: 0  # default to 'once'
      t.datetime :scheduled_at
      
      # Status
      t.integer :status, null: false, default: 0  # default to 'pending'
      
      # Soft delete
      t.datetime :deleted_at

      t.timestamps
    end
    
    # Indexes
    add_index :campaigns, :name, unique: true
    add_index :campaigns, :audience_ids, using: :gin
    add_index :campaigns, :status
    add_index :campaigns, :scheduled_at
    add_index :campaigns, :deleted_at
  end
end
