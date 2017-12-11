class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true
  # protect_from_forgery with: :exception

  before_action :authorize_current_activity, :unless => :devise_controller?

  def authorize_current_activity
    # See if we're coming in from another customer
    current_customer_id = Customer.current&.id
    previous_customer_id = session["customer_id"].to_i
    if current_customer_id && previous_customer_id > 0 && (previous_customer_id != current_customer_id)
      previous_customer = Customer.find_by(id: previous_customer_id)
      if previous_customer
        this_subdomain = Apartment::Tenant.current

        # See if we've got a link that allows us over to this other customer
        Apartment::Tenant.switch!(previous_customer.subdomain)
        previous_user_id = session["warden.user.user.key"]&.first&.first
        user_link = UserLink.find_by(user_id: previous_user_id, customer_id: current_customer_id)
        # On user_link we can see the link_user_id for who we should now be
        Apartment::Tenant.switch!(this_subdomain)

        # Re-do things so we're on as the right person
        sign_in(User.find(user_link.link_user_id), scope: :user) if user_link
      end
    end

    unless current_customer_id.nil?
      authenticate_user! unless (user_signed_in? || devise_controller?)
      # authorize_action_for current_activity unless ( devise_controller? && (!(self.is_a? Users::InvitationsController)) || ((self.is_a? Users::InvitationsController) && current_user.nil? )  || ((self.is_a? UsersController) && action_name == 'switch_account'))
      session["customer_id"] = current_customer_id
    end

  end
end
