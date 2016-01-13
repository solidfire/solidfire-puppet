require 'puppet/provider'
require 'puppet/util/network_device'
require 'puppet/util/network_device/solidfire/device'

class Puppet::Provider::Solidfire < Puppet::Provider

  def self.transport(args=nil)
    @device ||= Puppet::Util::NetworkDevice.current
    if not @device and Facter.value(:url)
      Puppet.debug "NetworkDevice::SolidFire: connecting via facter url."
      @device ||= Puppet::Util::NetworkDevice::Solidfire::Device.new(Facter.value(:url))
    elsif not @device and args and args.length == 1
      Puppet.debug "NetworkDevice::SolidFire: connecting via argument bits #{args[0]}."
      @device ||= Puppet::Util::NetworkDevice::Solidfire::Device.new(args[0])
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
    self.class.method_missing(name, args)
  end

  def conn_info
    if resource[:url] then resource[:url]
    elsif resource[:mvip] and resource[:login] and resource[:password]
      "https://" + resource[:login] + ":" + resource[:password] + "@" + resource[:mvip] + "/"
    else nil end
  end

end
