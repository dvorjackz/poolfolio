class SuggestionsController < ApplicationController
  before_action :set_suggestion, only: [:show, :edit, :update, :destroy]

  # GET /suggestions
  # GET /suggestions.json
  def index
    @suggestions = Suggestion.all
  end
  
  
  
  def execute
    @team = Team.find(@suggestion.team_id)
    @stock = Stock.find_by(ticker: @suggestion.ticker)

    ## should limiting @suggestion.quantity to ensure @holding.quantity >= 0 after selling and team has enough balance when purchasing.
    
    # 1. update holdings table
    @holding = Holding.find_by(team_id: @team.id, stock_id: @stock.id)
    if @holding != nil
      @holding.update_attribute(quantity, @holding.quantity + @suggestion.quantity)
      if @holding.quantity <= 0
        @holding.destroy
      end
    else
      @holding = Holding.create(team_id: @team.id, stock_id: @stock.id, quantity: @suggestion.quantity)
    end
      
    # 2. update teams table
    @team.update(value: @team.value + @stock.price * @suggestion.quantity, balance: @team.balance - @stock.price * @suggestion.quantity)
  end



  # GET /suggestions/1
  # GET /suggestions/1.json
  def show
  end

  # GET /suggestions/new
  def new
    @suggestion = Suggestion.new
  end

  # GET /suggestions/1/edit
  def edit
  end

  # POST /suggestions
  # POST /suggestions.json
  def create
    @suggestion = Suggestion.new(suggestion_params)

    respond_to do |format|
      if @suggestion.save
        format.html { redirect_to @suggestion, notice: 'Suggestion was successfully created.' }
        format.json { render :show, status: :created, location: @suggestion }
      else
        format.html { render :new }
        format.json { render json: @suggestion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /suggestions/1
  # PATCH/PUT /suggestions/1.json
  def update
    respond_to do |format|
      if @suggestion.update(suggestion_params)
        format.html { redirect_to @suggestion, notice: 'Suggestion was successfully updated.' }
        format.json { render :show, status: :ok, location: @suggestion }
      else
        format.html { render :edit }
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
      params.require(:suggestion).permit(:quantity)
    end
end
