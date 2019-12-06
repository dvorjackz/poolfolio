class SuggestionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_suggestion, only: [:show, :edit, :update, :destroy, :upvote, :downvote, :execute]
  before_action :prepare_team



  def prepare_team
    @team = Team.find(current_user.team_id)
  end

  #Voting - acts_as_votable: https://www.cryptextechnologies.com/blogs/voting-functionality-in-ruby-on-rails-app
  def upvote
    @suggestion.upvote_from current_user
    redirect_to current_user
  end

  def downvote
    @suggestion.downvote_from current_user
    redirect_to current_user
  end

  # only called by the upvote method above
  def execute
    # stock existence should be validated at creation
    @stock = Stock.find_by(ticker: @suggestion.ticker)
    price = nil

    # If the stock price is nil (the stock isn't currently active)
    if @stock.price == nil
      res = RestClient.get("https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=" + @stock.ticker + "&apikey=YNKAKVYRW2VHVAV1")
      res = JSON.parse(res)
      price = res["Global Quote"]["05. price"]
    else
      price = @stock.price
    end

    if @suggestion.quantity < 0
      # sell

      @holding = Holding.find_by(team_id: @team.id, stock_id: @stock.id)
      if @holding != nil
        quantity = [-@suggestion.quantity, @holding.quantity].min
        income = price * quantity
        res = @holding.update(quantity: @holding.quantity - quantity)
        if @holding.quantity == 0
          @holding.destroy
        end
        @team.update(balance: @team.balance + income, value: @team.value - income)
        if res == false
          redirect_to @suggestion, alert: "Invalid quantity." and return
        end
      else
        redirect_to current_user, notice: 'No such holding.' and return
      end

    else
      # buy
      # to_i converts nil to 0, @stock.price may be nil

      cost = price.to_i * @suggestion.quantity
      # @team.value is nil by default
      res = @team.update(balance: @team.balance - cost, value: @team.value.to_i + cost)
      if res == false
        redirect_to @suggestion, alert: "Insufficient Balance." and return
      end

      @holding = Holding.find_by(team_id: @team.id, stock_id: @stock.id)
      if @holding != nil
        @holding.update(quantity: @holding.quantity + @suggestion.quantity)
      else
        @holding = Holding.create(team_id: @team.id, stock_id: @stock.id, ticker: @stock.ticker, quantity: @suggestion.quantity, price: @stock.price, value: @stock.price * @suggestion.quantity)
      end
    end

    # Update stock with new price
    @stock.price = price.to_i
    @stock.save # "save" instead of "update_attribute", since the latter does not update the "updated_at" field
    @stock.touch # "save" only updates "updated_at" field if changes were made, "touch" guarantees "updated_at" is updated

    # if the above operations have been successfully executed or the holding to sell doesn't exist
    redirect_to current_user, notice: 'Suggestion was successfully executed.'
    @suggestion.destroy

  end

  # GET /suggestions/new
  def new
    @suggestion = Suggestion.new
  end

  # POST /suggestions
  # POST /suggestions.json
  def create
    @suggestion = @team.suggestions.build(suggestion_params)
    @suggestion.user_id = current_user.id

    respond_to do |format|
      if @suggestion.save
        format.html { redirect_to @current_user, notice: 'Suggestion was successfully created.' }
        format.json { render :show, status: :created, location: @suggestion }
      else
        format.html { render :new }
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /suggestions/1
  # DELETE /suggestions/1.json
  def destroy
    @suggestion.destroy
    respond_to do |format|
      format.html { redirect_to suggestions_url, notice: 'Suggestion was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_suggestion
      @suggestion = Suggestion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def suggestion_params
      params.require(:suggestion).permit(:quantity, :team_id, :user_id, :ticker)
    end
end
