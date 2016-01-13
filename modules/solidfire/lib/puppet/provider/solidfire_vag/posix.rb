require 'puppet/provider/solidfire'
require 'puppet/util/network_device'

Puppet::Type.type(:solidfire_vag).provide(:posix,
                                     :parent => Puppet::Provider::Solidfire) do
  desc "Manage SolidFire Volume Access Group creation, "\
       "modification and deletion."
  confine :feature => :posix

  mk_resource_methods

  def self.instances
    Puppet.debug("#{self.class}::self.instances.")
    vags = []
    begin
      vagList = transport.ListVolumeAccessGroups()['volumeAccessGroups']
    rescue Puppet::Error
      vags
    else
      vagList.each do |vag|
        vag_hash = get_vag_properties(vag)
        vags << new(vag_hash)
      end
      vags
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

  def self.get_vag_properties(vag)
    vag_hash = { :name          => vag['name'],
                 :ensure        => :present,
                 :vagid         => vag['volumeAccessGroupID"'],
                 :volumes       => vag['volumes'],
                 :initiators    => vag['initiators'],
                }
  end

  def set_vag

    if vag = transport(conn_info).getVagByName(@resource[:name])
      vag_id = vag['volumeAccessGroupID']
    end

    if @property_flush[:ensure] == :absent
      Puppet.debug("#{self.class}::Delete VAG ID #{vol_id}")
      transport(conn_info).DeleteVolumeAccessGroup( { "volumeAccessGroupID" =>
                                                       vag_id })
      return
    end

    # convert the volume list from names to ids
    volumes = transport(conn_info).ListActiveVolumes()['volumes'] |
                     transport(conn_info).ListDeletedVolumes()['volumes']
    vol_ids=[]
    @resource[:volumes].each do |name|
      vol_ids << volumes.map { |x| x['volumeID'] if x['name'] == name }
    end
    vol_ids = vol_ids.flatten.compact

    if vag_id
      # vag exists modify
      # got vag as it exists, since we are here, we have checked it exists
      # check for and delete initiators as needed
      delinit = (vag['initiators']-@resource[:initiators])
      transport(conn_info).RemoveInitiatorsFromVolumeAccessGroup(
                                       { "volumeAccessGroupID" => vag_id,
                                         "initiators"          => delinit, } )
      # check for and delete volumes as needed
      delvol = (vag['volumes']-vol_ids)
      transport(conn_info).RemoveVolumesFromVolumeAccessGroup(
                                       { "volumeAccessGroupID" => vag_id,
                                         "volumes"             => delvol, } )
      # now just add the new initiators and volumes
      transport(conn_info).ModifyVolumeAccessGroup(
                                   { "volumeAccessGroupID" => vag_id,
                                     "name" => @resource[:name],
                                     "initiators" => @resource[:initiators],
                                     "volumes" => vol_ids, })
    else
      # vag doesn't exist create
      Puppet.debug "Create Volume Access Group"
      vag_id = transport(conn_info).CreateVolumeAccessGroup(
                                    {"name" => @resource[:name],
                                     "initiators" => @resource[:initiators],
                                     "volumes" => vol_ids,}
                                   )['volumeAccessGroupID']
    end
    vag_id
  end

  def flush
    Puppet.debug("#{self.class}::flush")
    if vag_id = set_vag
      vag = transport(conn_info).getVagByID(vag_id)
      @property_hash = self.class.get_vag_properties(vag)
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
    elsif vag = transport(conn_info).getVagByName(@resource[:name])
        @property_hash = self.class.get_vag_properties(vag)
        true
    else false end
  end

end
