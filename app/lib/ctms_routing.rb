module CtmsRouting
  def self.root
    "http://lvh.me:3000"
  end
  def self.excluded_subdomains
    ['www', 'dev', 'prod']
  end
end
