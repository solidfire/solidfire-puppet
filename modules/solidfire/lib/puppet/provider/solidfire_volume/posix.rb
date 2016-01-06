require 'puppet/provider/solidfire'
require 'puppet/util/network_device'

Puppet::Type.type(:solidfire_volume).provide(:posix, :parent => Puppet::Provider::Solidfire) do
  desc "Manage SolidFire Volume creation, modification and deletion."
  confine :feature => :posix

  mk_resource_methods

  def self.instances
    Puppet.debug("#{self.class}::self.instances.")
    volumes = []
    begin
      volList = transport.ListActiveVolumes()['volumes']
    rescue Puppet::Error
      volumes
    else
      volList.each do |vol|
        vol_hash = get_volume_properties(vol)
        volumes << new(vol_hash)
      end
      volumes
    end
  end

  def self.prefetch(resources)
    Puppet.debug("#{self.class}::self.prefetch.")
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.get_volume_properties(vol)
    acct_name = transport.GetAccountByID({'accountID' => vol['accountID'] \
                                 })['account']['username']
    vol_hash = { :accountname   => acct_name,
                 :name          => vol['name'],
                 :ensure        => :present,
                 :size          => ( vol['totalSize'] / 1000000000 ).to_s,
                 :min_iops      => vol['qos']['minIOPS'],
                 :max_iops      => vol['qos']['maxIOPS'],
                 :burst_iops    => vol['qos']['burstIOPS'],
                 :volumeid      => vol['volumeID"'],
                }
  end

  def set_volume
    if vol = transport(conn_info).getVolumeByName(@resource[:name])
      vol_id = vol['volumeID']
    end
    if @property_flush[:ensure] == :absent
      Puppet.debug("#{self.class}::Delete VolumeID #{vol_id}")
      transport(conn_info).DeleteVolume( { "volumeID" => vol_id })
      return
    else
      size = Integer(@resource[:size]) * 1000000000
      acct_id = transport(conn_info).GetAccountByName({'username' => \
                        @resource[:accountname]})['account']['accountID']
      if vol_id
        # vol exists modify
        transport(conn_info).ModifyVolume({ "volumeID" => vol_id,
                                            "accountID" => acct_id,
                                            "totalSize" => size,
                                            "qos" => 
                                      { "minIOPS" => @resource[:min_iops],
                                        "maxIOPS" => @resource[:max_iops],
                                        "burstIOPS" => @resource[:burst_iops]}})
      else
        # vol doesn't exist create
        Puppet.debug "Create Volume"
        vol_id = transport(conn_info).CreateVolume({"name" => @resource[:name],
                                                    "accountID" => acct_id,
                                                    "totalSize" => size,
                                                    "enable512e" => true,
                                                    "qos" =>
                                    { "minIOPS" => @resource[:min_iops],
                                      "maxIOPS" => @resource[:max_iops],
                                      "burstIOPS" => @resource[:burst_iops]}}
                                   )['volumeID']
      end
    vol_id
    end
  end

  def flush
    Puppet.debug("#{self.class}::flush")
    if vol_id = set_volume
      vol = transport(conn_info).getVolumeByID(vol_id)
      @property_hash = self.class.get_volume_properties(vol)
    end
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def exists?
    Puppet.debug "#{self.class}::exists?"
    if @property_hash[:ensure] == :present then true
    elsif volume = transport(conn_info).getVolumeByName(@resource[:name])
        @property_hash = self.class.get_volume_properties(volume)
        true
    else false end
  end

end
