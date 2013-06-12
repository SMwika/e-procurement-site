class AddConfirmationToUsers < ActiveRecord::Migration
  def change
    ## Confirmable
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string


    ## Token authenticatable
    add_column :users, :authentication_token, :string


    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :authentication_token, :unique => true
  end
end
