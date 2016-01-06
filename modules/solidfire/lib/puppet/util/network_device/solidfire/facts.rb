require 'puppet/util/network_device/solidfire'

class Puppet::Util::NetworkDevice::Solidfire::Facts

  attr_reader :transport, :url
  def initialize(transport)
    @transport = transport
  end

  def retrieve
    Puppet.debug "Retrieving Facts from #{@transport.redacted_url}"
    @facts = {}
    @facts[:url] = @transport.url.to_s
    
    @facts
  end
end

=begin
{
"id" : 1,
"result" : {
"clusterInfo" : {
"attributes" : {},
"encryptionAtRestState" : "disabled",
"ensemble" : [ "10.10.5.42",
"10.10.5.43",
"10.10.5.44",
"10.10.5.46",
"10.10.5.47"
],
"mvip" : "192.168.155.200",
"mvipNodeID" : 5,
"name" : "QoS",
"repCount" : 2,
"svip" : "10.10.20.200",
"svipNodeID" : 5,
"uniqueID" : "bidi",
"uuid" : "fa30f0f8-7697-4fdc-bf31-353e47c61347"
}
}
}
=end
