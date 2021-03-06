class AddUpdatedToCoreTables < ActiveRecord::Migration
  def change
    add_column :tenders, :updated, :boolean
    add_column :organizations, :updated, :boolean
    add_column :agreements, :updated, :boolean
    add_column :bidders, :updated, :boolean
    add_column :documents, :updated, :boolean

    add_column :tenders, :is_new, :boolean
    add_column :organizations, :is_new, :boolean
    add_column :agreements, :is_new, :boolean
    add_column :bidders, :is_new, :boolean
    add_column :documents, :is_new, :boolean
  end
end
