class AddSubjectAndBodyToCampaigns < ActiveRecord::Migration[8.1]
  def change
    add_column :campaigns, :subject, :string
    add_column :campaigns, :body, :text
  end
end
