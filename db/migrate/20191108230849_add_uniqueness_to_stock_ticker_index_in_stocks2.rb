class AddUniquenessToStockTickerIndexInStocks2 < ActiveRecord::Migration[6.0]
  def change
    add_index :stocks, :ticker, unique: true
  end
end
