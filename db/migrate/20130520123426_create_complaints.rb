class CreateComplaints < ActiveRecord::Migration
  def change
    create_table :complaints do |t|
      t.integer :organization_id
      t.string :status
      t.integer :tender_id
      t.date :issue_date
      t.text :complaint
      t.string :legal_basis
      t.text :demand
      t.timestamps
    end
  end
end
