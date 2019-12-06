class UsersController < ApplicationController

  before_action :authenticate_user!, :check_user, :set_teams

  def show
    # "stocks" structure combines stock price from Stock and quantity from Holding
    @stocks = Array.new
    @stocks = Holding.where(team_id: current_user.team_id).order("value desc").paginate(page: params[:holding_page], :per_page => 20)
    @teams = Team.order("balance + value desc").paginate(page: params[:team_page], :per_page => 22)

    # Optimization, all suggestions are loaded 8 at a time
    @suggestions = @team.suggestions.paginate(page: params[:suggestion_page], :per_page => 8)

  end

  def index
    @users = User.all
  end

  private

    def set_teams
      @team = Team.find(current_user.team_id)
      # @teams = Team.all.sort_by{ |team| team.balance + team.value}.reverse[0...19]
    end

    def check_user
      if current_user != User.find(params[:id])
        redirect_to login_path, alert: "Please login to access your homepage."
      end
    end

end
