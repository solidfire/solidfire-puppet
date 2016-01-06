require 'puppet/util/network_device'
require 'puppet/util/network_device/solidfire/facts'
require 'puppet/solidfire_api'

class Puppet::Util::NetworkDevice::Solidfire::Device

  attr_accessor :transport
  def initialize(url, option = {})
    @transport = SolidfireApi.new(url)
    if Puppet[:debug]
      @transport.debug = true
    end

    Puppet.debug("#{self.class}: connecting to SolidFire device " \
                 "#{@transport.redacted_url}")
  end

  def facts
    Puppet.debug("#{self.class}.facts: connecting to SolidFire device " \
                 "#{@transport.url.host}")
    @facts ||= Puppet::Util::NetworkDevice::Solidfire::Facts.new(@transport)
    thefacts = @facts.retrieve
    thefacts
  end

end
