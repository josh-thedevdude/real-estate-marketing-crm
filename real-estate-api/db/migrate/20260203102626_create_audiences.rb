class CreateAudiences < ActiveRecord::Migration[8.1]
  def change
    create_table :audiences do |t|
      # Foreign keys - created_by is NOT NULL
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      
      # Audience details
      t.string :name, null: false
      t.text :description
      
      # JSONB filters
      t.jsonb :filters, default: {}
      
      # Soft delete
      t.datetime :deleted_at

      t.timestamps
    end
    
    # Indexes
    add_index :audiences, :name, unique: true
    add_index :audiences, :deleted_at
    add_index :audiences, :filters, using: :gin
  end
end
