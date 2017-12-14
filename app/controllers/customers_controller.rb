class CustomersController < ApplicationController
  before_action :set_customer, only: [:edit, :update, :destroy]

  # GET /customers
  # GET /customers.json
  def index
    @customers = Customer.all
    @current_customer_id = Customer.current&.id
    @linked_customer_ids = current_user&.origin_user_links&.map(&:link_customer_id) || []
  end

  def widget_counts
    customers = Customer.select(:id, :subdomain)
    sql = customers.map{|c| "SELECT #{c.id} AS customer_id, COUNT(*) AS count FROM #{c.subdomain}.widgets\n"}.
      join("UNION ALL\n")
    counts = ActiveRecord::Base.connection.execute(sql)
    render json: {current_customer_id: session[:customer_id],
        # current_user_id: session["warden.user.user.key"]&.first&.first,
        current_user_id: session["link_user_id"],
        counts: counts
      }
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers
  # POST /customers.json
  def create
    @customer = Customer.new(customer_params)
    @customer.active = true

    respond_to do |format|
      if @customer.save
        format.html { redirect_to customers_path, notice: 'Customer was successfully created.' }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to customers_path, notice: 'Customer was successfully updated.' }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(:subdomain)
    end
end
