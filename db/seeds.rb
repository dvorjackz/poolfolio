require 'securerandom'
# Check so that each newly spawned EB instance doesn't try to seed and already seeded database
if Team.all.size == 0
  # puts "Hello, Ruby!";
  # Default team which esvery new user joins
  first_user = User.create(firstname: "Jack", lastname: "Zhang", email: "jz@ucla.edu", password: "qwerty", password_confirmation: "qwerty", team_id: 1)
  second_user = User.create(firstname: "Pierson", lastname: "Marks", email: "pm@ucla.edu", password: "qwerty", password_confirmation: "qwerty", team_id: 1)
  third_user = User.create(firstname: "Hanyo", lastname: "Liu", email: "hl@ucla.edu", password: "qwerty", password_confirmation: "qwerty", team_id: 1)
  fourth_user = User.create(firstname: "Nikita", lastname: "Luyanenko", email: "nikita1923666@gmai.com", password: "warlords", password_confirmation: "warlords", team_id: 1)
  first_team = Team.create(name: "The Quants", balance: 4000)
  second = Team.create(name: "PYPL", balance: 4000)
  third = Team.create(name: "AMZN", balance: 4000)
  fourth = Team.create(name: "UBER", balance: 4000)
  fifth = Team.create(name: "Microsoft", balance: 4000)
  first_suggestion1 = Suggestion.create(quantity: 500, team_id: 1, user_id: 1, ticker: 'QUAN')
  first_suggestion2 = Suggestion.create(quantity: 500, team_id: 2, user_id: 2, ticker: 'QUAN')
  first_suggestion3 = Suggestion.create(quantity: 500, team_id: 3, user_id: 3, ticker: 'QUAN')
  first_suggestion4 = Suggestion.create(quantity: 500, team_id: 4, user_id: 4, ticker: 'QUAN')
  first_suggestion5 = Suggestion.create(quantity: 500, team_id: 5, user_id: 5, ticker: 'QUAN')
  second_suggestion1 = Suggestion.create(quantity: 500, team_id: 1, user_id: 1, ticker: 'PYPL')
  second_suggestion2 = Suggestion.create(quantity: 500, team_id: 2, user_id: 2, ticker: 'PYPL')
  second_suggestion3 = Suggestion.create(quantity: 500, team_id: 3, user_id: 3, ticker: 'PYPL')
  second_suggestion4 = Suggestion.create(quantity: 500, team_id: 4, user_id: 4, ticker: 'PYPL')
  second_suggestion5 = Suggestion.create(quantity: 500, team_id: 5, user_id: 5, ticker: 'PYPL')
  third_suggestion1 = Suggestion.create(quantity: 500, team_id: 1, user_id: 1, ticker: 'AMZN')
  third_suggestion2 = Suggestion.create(quantity: 500, team_id: 2, user_id: 2, ticker: 'AMZN')
  third_suggestion3 = Suggestion.create(quantity: 500, team_id: 3, user_id: 3, ticker: 'AMZN')
  third_suggestion4 = Suggestion.create(quantity: 500, team_id: 4, user_id: 4, ticker: 'AMZN')
  four_suggestion5 = Suggestion.create(quantity: 500, team_id: 5, user_id: 5, ticker: 'AMZN')
  five_suggestion1 = Suggestion.create(quantity: 500, team_id: 1, user_id: 1, ticker: 'UBER')
  five_suggestion2 = Suggestion.create(quantity: 500, team_id: 2, user_id: 2, ticker: 'UBER')
  five_suggestion3 = Suggestion.create(quantity: 500, team_id: 3, user_id: 3, ticker: 'UBER')
  five_suggestion4 = Suggestion.create(quantity: 500, team_id: 4, user_id: 4, ticker: 'UBER')
  five_suggestion5 = Suggestion.create(quantity: 500, team_id: 5, user_id: 5, ticker: 'UBER')
  200.times do
    newname = SecureRandom.hex(7)
    first_user = User.create(firstname: newname, lastname: newname, email: newname + "@ucla.edu", password: newname, password_confirmation: newname, team_id: 5)
  end
  i = 1
  tickers = ["MSFT", "GOOG", "AAPL", "V", "COUP", "OKTA", "AMZN", "WORK", "NOW", "BRK.B"]
  200.times do
    name = SecureRandom.hex(7)
    Team.create(name: name, balance: rand(400...5000))
    10.times do
      name2 = SecureRandom.hex(12)
      Suggestion.create(quantity: rand(-500...500), team_id: i+5, user_id: 1, ticker: tickers.sample)
    end
    i += 1
  end
  # Stocks using Alpaca's Market API
  res = RestClient.get("https://paper-api.alpaca.markets/v2/assets", :"APCA-API-KEY-ID" => "PKI9MD0KBM4B957XF9IJ", :"APCA-API-SECRET-KEY" => "DxnPxsIzEZDwFcgfnlHoSKhkKFsfEgsHFkggmcQx")
  res = JSON.parse(res)
  for stock in res do
    if (stock["exchange"] == "NYSE" ||
        stock["exchange"] == "AMEX" ||
        stock["exchange"] == "NASDAQ") &&
        stock["tradable"] == true
      Stock.create(ticker: stock["symbol"], exchange: stock["exchange"])
    end
  end
end
