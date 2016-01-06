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
        Puppet.debug("user -> #{vol_hash}")
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
    Puppet.debug("#{self.class}::initialize #{value}")
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
    if @property_flush[:ensure] == :absent
      # volume is being deleted ... delete
      transport.DeleteVolume( { "volumeID" => @property_hash[:volumeid] })
      return
    end
    size = Integer(resource[:size]) * 1000000000
    acct_id = transport.GetAccountByName({'username' => \
                  resource[:accountname]})['account']['accountID']
    vol_id = transport.CreateVolume({"name" => resource[:name],
                           "accountID" => acct_id,
                           "totalSize" => size,
                           "enable512e" => true,
                           "qos" => { "minIOPS" => resource[:min_iops],
                                      "maxIOPS" => resource[:max_iops],
                                      "burstIOPS" => resource[:burst_iops]}}
                                   )['volumeID']
    vol_id
  end

  def flush
    Puppet.debug("#{self.class}::flush")
    begin
      transport
    rescue
      transport("https://" + resource[:login] + ":" + resource[:password] + \
                "@" + resource[:mvip] + "/" )
    end
    if vol_id = set_volume
      vol = transport.getVolumeByID(vol_id)
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
    if @property_hash[:ensure] == :present
      true
    else
      begin
        volume = transport("https://" + resource[:login] + ":" + \
                 resource[:password] + "@" + resource[:mvip] + "/" ).
                 getVolumeByName(@resource[:name])
      rescue
      end
      if volume
        @property_hash = self.class.get_volume_properties(volume)
        true
      else
        false
      end
    end
  end

end
