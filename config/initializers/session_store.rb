# Be sure to restart your server when you modify this file.

# tld_length must be set according to the URL where the system is deployed.  For instance,
# a domain of lvh.me has 2 parts, and when subdomains are added for, say, customer1.lvh.me, this
# allows all cookies to be stored related to .lvh.me, and as people navigate through the site,
# they remain logged in as the same user.  For more information:
#   https://stackoverflow.com/questions/18492576/share-cookie-between-subdomain-and-domain

root_url = CtmsRouting.root
uri = URI.parse(root_url)
current_hostname = uri.hostname.split(".")
starts_with_excluded = CtmsRouting.excluded_subdomains.include?(current_hostname.first)
tld_length = 2 + (starts_with_excluded ? 1 : 0)
Rails.application.config.session_store :cookie_store, key: '_ApartmentDevise1_session', domain: :all, tld_length: tld_length
