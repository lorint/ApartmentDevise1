class UserLinksController < ApplicationController
  # POST /user_link
  # POST /user_link.json
  def create
    this_subdomain = Apartment::Tenant.current
    # Find or create related user in other customer
    other_customer = Customer.find(params[:customer_id])

    Apartment::Tenant.switch!(other_customer.subdomain)
    user = User.find_by(email: current_user.email)
    user ||= User.create(email: current_user.email, password: "password", password_confirmation: "password")
    Apartment::Tenant.switch!(this_subdomain)

    user_link = current_user.origin_user_links.new({link_customer_id: other_customer.id, user_id: user.id})

    respond_to do |format|
      if user_link.save
        format.html { redirect_to customers_path, notice: 'UserLink was successfully created.' }
        format.json { render :show, status: :created, location: user_link }
      else
        binding.pry
        format.html { render :new }
        format.json { render json: user_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_links/1
  # DELETE /user_links/1.json
  def destroy
    UserLink.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to customers_path, notice: 'UserLink was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end
