class CreateHoldings < ActiveRecord::Migration[6.0]
  def change
    create_table :holdings do |t|
      t.integer :quantity

      t.timestamps
    end
  end
end
