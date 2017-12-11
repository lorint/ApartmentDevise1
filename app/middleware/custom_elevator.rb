class CustomElevator < Apartment::Elevators::Subdomain

  def call(*args)
    begin
      super
    rescue Apartment::TenantNotFound
      Rails.logger.error "ERROR: Apartment Tenant not found: #{Apartment::Tenant.current.inspect}"
      return [404, {"Content-Type" => "text/html"}, ["#{File.read(Rails.root.to_s + '/public/404.html')}"] ]
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error "ERROR: #{e.message}"
      if e.message == 'Customer is disabled'
        return [404, {"Content-Type" => "text/html"}, ["#{File.read(Rails.root.to_s + '/public/disabled_customer.html')}"] ]
      else
        return [404, {"Content-Type" => "text/html"}, ["#{File.read(Rails.root.to_s + '/public/404.html')}"] ]
      end
    end

  end

  def parse_tenant_name(request)
    tenant = if self.class.excluded_subdomains.include?(subdomain(request.host))
          nil
        else
          subdomain(request.host)
        end
    if (tenant.present? && (Customer.inactive.pluck(:subdomain).include? tenant))
      raise ActiveRecord::StatementInvalid.new("Customer is disabled")
    else
      super
    end

  end
end
