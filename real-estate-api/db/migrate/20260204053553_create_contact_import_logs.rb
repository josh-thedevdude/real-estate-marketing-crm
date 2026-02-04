class CreateContactImportLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_import_logs do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :job_id, null: false
      t.string :filename, null: false
      t.integer :total_rows, default: 0, null: false
      t.integer :successful_rows, default: 0, null: false
      t.integer :failed_rows, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.jsonb :error_details, default: [], null: false

      t.timestamps
    end
    
    add_index :contact_import_logs, :job_id, unique: true
    add_index :contact_import_logs, :status
    add_index :contact_import_logs, :created_at
  end
end
