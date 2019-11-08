class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @teams = Team.all.order("created_at DESC")
    @team = Team.find(@user.team_id)
    @stocks = Array.new
    Holding.where(team_id: @user.team_id).each do |holding|
      @stocks.push({
        "quantity" => holding.quantity,
        stock => Stock.find(holding.stock_id),
        "ticker" => stock.ticker,
        "price" => number_to_currency(stock.price),
        "total" => number_to_currency(stock.price * holding.quantity)
      })
    end
  end

  def index
    @users = User.all
  end

  before_action :authenticate_user!, :check_user

  private

    def check_user
      if current_user != User.find(params[:id])
        redirect_to login_path, alert: "Please login to access your homepage."

      end
    end
end
