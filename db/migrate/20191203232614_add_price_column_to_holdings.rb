class AddPriceColumnToHoldings < ActiveRecord::Migration[6.0]
  def change
    add_column :holdings, :price, :integer
  end
end
