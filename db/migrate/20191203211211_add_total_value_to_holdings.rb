class AddTotalValueToHoldings < ActiveRecord::Migration[6.0]
  def change
    add_column :holdings, :value, :integer
  end
end
