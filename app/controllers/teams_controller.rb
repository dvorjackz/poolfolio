class TeamsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_team, only: [:show, :edit, :update, :destroy, :join]
  before_action :authenticate_user!, only: [:join, :create, :index]


  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all.order("created_at DESC")
  end

  def join
    # Everytime a user joins a new team, the current team loses $1000 and the new team gains $1000
    current_team = Team.find(current_user.team_id)
    current_team.update_attribute(:balance, current_team.balance -= 1000)
    @team.update_attribute(:balance, @team.balance += 1000)

    # Switch teams
    current_user.update_attribute(:team_id, @team.id)
    redirect_to current_user
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @users = User.where(team_id: @team.id)
  end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(team_params)
    # Add 1000 to the newly created team and subtract 1000 from the team that the user left
    current_team = Team.find(current_user.team_id)
    current_team.update_attribute(:balance, current_team.balance -= 1000)
    @team.update_attribute(:balance, @team.balance += 1000)


    respond_to do |format|
      if @team.save
        current_user.update_attribute(:team_id, @team.id)
        format.html { redirect_to @team, notice: 'Team was successfully created.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to teams_url, notice: 'Team was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_team
      @team = Team.find(params[:id]) #This doesn't make sense. Why are we searching for a team that matches the User id?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def team_params
      params.require(:team).permit(:name)
    end
end
