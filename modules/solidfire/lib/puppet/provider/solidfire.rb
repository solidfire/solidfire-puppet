require 'puppet/provider'
require 'puppet/util/network_device'
require 'puppet/util/network_device/solidfire/device'

class Puppet::Provider::Solidfire < Puppet::Provider

  def self.transport(args=nil)
    if Facter.value(:url) then
      Puppet.debug "Puppet::Util::NetworkDevice::SolidFire: connecting via " \
                   "facter url."
      @device ||= Puppet::Util::NetworkDevice::Solidfire::Device.new(Facter.value(:url))
    elsif args && args.length == 1
      Puppet.debug "args: #{args}"
      Puppet.debug "Puppet::Util::NetworkDevice::SolidFire: connecting via " \
                   "argument url #{args[0]}"
      @device ||= Puppet::Util::NetworkDevice::Solidfire::Device.new(args[0])
    else
      Puppet.debug "Puppet::Util::NetworkDevice::SolidFire: reconnecting"
      @device ||= Puppet::Util::NetworkDevice.current
    end
    raise Puppet::Error, "#{self.class} : device not initialized " \
                           "#{caller.join("\n")}" unless @device
    @transport = @device.transport
  end

  def transport(*args)
    # this calls the class instance of self.transport instead of the object
    # instance which causes an infinite loop.
    self.class.transport(args)
  end

  def method_missing(name, *args)
    Puppet.debug("#{self.class}::instance method_missing: #{name}")
    self.class.method_missing(name, args)
  end

end
