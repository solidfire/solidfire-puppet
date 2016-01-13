#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/

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
