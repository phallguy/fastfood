module Fastfood::Extensions::Server
  def internal_hostname
    fetch(:internal_hostname) || hostname
  end

  def ip_addresses
    @ip_addresses ||= Fastfood.ip_addresses( hostname )
  end

  def internal_ip_addresses
    @internal_ip_addresses ||= Fastfood.ip_addresses( internal_hostname )
  end
end

class Capistrano::Configuration::Server
  include Fastfood::Extensions::Server
end