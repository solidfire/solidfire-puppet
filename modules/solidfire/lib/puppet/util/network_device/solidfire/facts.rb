require 'puppet/util/network_device/solidfire'

class Puppet::Util::NetworkDevice::Solidfire::Facts

  attr_reader :transport, :url
  def initialize(transport)
    @transport = transport
  end

  def retrieve
    Puppet.debug "Retrieving Facts from #{@transport.redacted_url}"
    @facts = {}
    @facts["url"] = @transport.url.to_s
    clusterinfo = @transport.GetClusterInfo({})
    @facts["vendor_id"] = 'SolidFire'
    @facts.merge!(clusterinfo)
    @facts
  end
end
