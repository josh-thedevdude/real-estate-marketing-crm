class CreateEmailTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :email_templates do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :subject, null: false
      t.text :body, null: false
      t.jsonb :variables, default: {}, null: false
      t.datetime :deleted_at

      t.timestamps
    end
    
    add_index :email_templates, [:organization_id, :name], 
              unique: true, 
              where: "deleted_at IS NULL",
              name: "index_email_templates_on_org_and_name"
    add_index :email_templates, [:organization_id, :deleted_at]
    add_index :email_templates, :deleted_at
  end
end
