# If update_period = 5 minutes, then there are a total capacity of 5 minutes * 5 requests / minute = 25
# stocks able to be refreshed every period. Thus, the number of unique stocks being held by any team
# must be less than or equal to 25. Increasing update_period results in a slower refresh rate but a higher
# stock update capacity. 
update_period = 30 # (in minutes)

namespace :update do

  # The actual stock update task
  desc "Update all stocks currently being held by any team, and concurrently updates team values"
  task update_stocks: :environment do
    puts "Environment: " + ENV["RAILS_ENV"]

    teams = Team.all
    api_limit_reached = false

    for team in teams do
      puts "--------------------------> Updating " + team.name + "'s stocks..."

      suggestions = Suggestion.where(team_id: team.id)
      for suggestion in suggestions do
        stock = Stock.where(ticker: suggestion.ticker)[0]
        if api_limit_reached == false && (stock.updated_at < update_period.minutes.ago || stock.price == nil)
          # Obtain price of stock using AlphaVantage API
          res = RestClient.get("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=" + stock.ticker + "&apikey=YNKAKVYRW2VHVAV1")
          res = JSON.parse(res)
          
          # 5 stocks have been updated, so start skipping stock updates and just proceed to updating team values with the 5 newly updated stocks
          if res.key?("Note") == true
            api_limit_reached = true
          else
            res_price = res["Global Quote"]["05. price"]

            # Update stock with new price
            stock.price = res_price.to_i
            stock.save # "save" instead of "update_attribute", since the latter does not update the "updated_at" field
            stock.touch # "save" only updates "updated_at" field if changes were made, "touch" guarantees "updated_at" is updated

            puts "#{Time.now} - Updated " + stock.ticker + "'s stock price to: " + res_price
          end
        end
      end

      holdings = Holding.where(team_id: team.id)
      new_team_value = 0 # For adding up the team's new value from each holding
      for holding in holdings do
        stock = Stock.find(holding.stock_id)
        # Only update the stock if it has been stale for a specified number of minutes
        if api_limit_reached == false && (stock.updated_at < update_period.minutes.ago || stock.price == nil)
          # Obtain price of stock using AlphaVantage API
          res = RestClient.get("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=" + stock.ticker + "&apikey=YNKAKVYRW2VHVAV1")
          res = JSON.parse(res)
          
          # 5 stocks have been updated, so start skipping stock updates and just proceed to updating team values with the 5 newly updated stocks
          if res.key?("Note") == true
            api_limit_reached = true
          else
            res_price = res["Global Quote"]["05. price"]

            # Update stock with new price
            stock.price = res_price.to_i
            stock.save # "save" instead of "update_attribute", since the latter does not update the "updated_at" field
            stock.touch # "save" only updates "updated_at" field if changes were made, "touch" guarantees "updated_at" is updated

            # Update price in holding (holding is saved later outside the loop)
            holding.price = stock.price

            puts "#{Time.now} - Updated " + stock.ticker + "'s stock price to: " + res_price
          end
        end

        # Update holding value with stock price
        holding.value = stock.price * holding.quantity
        puts "!!!!!!!!!!!!!! Updated holdidngs: " + (holding.value).to_s + " !!!!!!!!!!!!!!!!!@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        holding.save

        # Add up the team's holding values
        new_team_value += holding.quantity * stock.price
      end
      team.value = new_team_value
      team.save

      puts "#{Time.now} - Done. " + team.name + "'s new value: " + new_team_value.to_s

    end
  end

end
