class AddDefaultForPriceAndValueForHoldings < ActiveRecord::Migration[6.0]
  def change
    change_column :holdings, :price, :integer, default: 0
    change_column :holdings, :value, :integer, default: 0
  end
end
