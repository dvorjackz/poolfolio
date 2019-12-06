class AddTickerToHoldings < ActiveRecord::Migration[6.0]
  def change
    add_column :holdings, :ticker, :string
  end
end
