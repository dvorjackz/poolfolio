class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  protect_from_forgery :except => :create


  before_action :configure_permitted_parameters, if: :devise_controller?



  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  protected

    def configure_permitted_parameters
      register_attrs = [:firstname, :lastname, :team_id]
      devise_parameter_sanitizer.permit(:sign_up, keys: register_attrs)

      update_attrs = [:firstname, :lastname, :password, :password_confirmation, :current_password]
      devise_parameter_sanitizer.permit(:account_update, keys: update_attrs)
    end

    # def after_sign_in_path_for(resource)
    #     user_path(resource)
    # end
    #
    # def after_update_path_for(resource)
    #   user_path(resource)
    # end
end
