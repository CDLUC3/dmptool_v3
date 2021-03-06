class AddLogoToOauthApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_applications, :logo_uid, :string
    add_column :oauth_applications, :logo_name, :string
    add_column :oauth_applications, :callback_uri, :string
    add_column :oauth_applications, :callback_method, :integer
  end
end
