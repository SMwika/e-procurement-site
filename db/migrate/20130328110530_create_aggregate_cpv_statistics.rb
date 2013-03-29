class CreateAggregateCpvStatistics < ActiveRecord::Migration
  def change
    create_table :aggregate_cpv_statistics do |t|
      t.integer :aggregate_statistic_type_id
      t.integer :cpv_code
      t.decimal :value, :precision => 11, :scale => 2
      t.timestamps
    end
  end
end
