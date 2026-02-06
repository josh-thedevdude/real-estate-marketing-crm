class CreateAudienceContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :audience_contacts do |t|
      t.references :audience, null: false, foreign_key: { on_delete: :cascade }
      t.references :contact, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
    
    add_index :audience_contacts, [:audience_id, :contact_id], unique: true, name: 'index_audience_contacts_on_audience_and_contact'
  end
end
