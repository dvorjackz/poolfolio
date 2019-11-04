class AddTeamIdIndexToUsers < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :team_id
  end
end
