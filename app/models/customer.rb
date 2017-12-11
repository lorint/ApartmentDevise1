class Customer < ApplicationRecord
  has_many :user_links
  before_validation :downcase_subdomain
  after_create :create_customer_tenant

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  after_initialize :set_defaults

  def set_defaults
    self.active ||= true if self.new_record?
  end

  def self.current
    Customer.active.find_by(subdomain: Apartment::Tenant.current)
  end

  # Find any destination links for a given user in this customer
  def destination_user_links(user)
    this_subdomain = Apartment::Tenant.current
    return nil if self.subdomain == this_subdomain

    Apartment::Tenant.switch!(self.subdomain)
    user_links = UserLink.where(link_user_id: user.id)
    Apartment::Tenant.switch!(this_subdomain)

    user_links
  end

  private
  def create_customer_tenant
    Apartment::Tenant.create(subdomain)
  end

  def downcase_subdomain
    if self.subdomain
      self.subdomain.downcase!
    end
  end
end
