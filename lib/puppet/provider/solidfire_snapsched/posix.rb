#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/

require 'puppet/provider/solidfire'
require 'puppet/util/network_device'

Puppet::Type.type(:solidfire_snapsched).provide(:posix,
                                     :parent => Puppet::Provider::Solidfire) do
  desc "Manage SolidFire Volume snapshot schedules, "\
       "modification and deletion."
  confine :feature => :posix

  mk_resource_methods

  def self.instances
    Puppet.debug("#{self.class}::self.instances.")
    scheds = []
    begin
      schedList = transport.ListSchedules()['schedules']
    rescue Puppet::Error
      scheds
    else
      schedList.each do |sched|
        sched_hash = get_sched_properties(sched)
        scheds << new(sched_hash)
      end
      scheds
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

  def self.get_sched_properties(sched)
    sched_hash = { :name          => sched['scheduleName'],
                   :ensure        => :present,
                   :schedid       => sched['scheduleID'],
                   :attributes    => sched['attributes']['frequency'],
                   :hours         => sched['hours'],
                   :minutes       => sched['minutes'],
                   :recurring     => sched['recurring'],
                   :retention     => sched['scheduleInfo']['retention'],
                   :snapname      => sched['scheduleInfo']['name'],
                   :startdate     => sched['startingDate'],
                  }

    monthdays = sched['monthdays'].map(&:to_s)
    sched_hash[:monthdays] = monthdays.uniq
    weekdays = []
    sched['weekdays'].each { |weekday| weekdays << weekday['day'].to_s }
    weekdays.uniq
    sched_hash[:weekdays] = weekdays

    if sched['scheduleInfo'].has_key?('volumeID')
      vols = [ sched['scheduleInfo']['volumeID'] ]
    else
      vols = sched['scheduleInfo']['volumes']
    end
    sched_hash[:volumes] = vols
    sched_hash
  end

  def set_sched

    if sched = transport(conn_info).getSchedByName(@resource[:name])
      schedid = sched['scheduleID']
    end

    if @property_flush[:ensure] == :absent
      Puppet.debug("#{self.class}::Delete schedule ID #{schedid}")
      transport(conn_info).ModifySchedule( { "toBeDeleted" => "true",
                                              "scheduleID" => schedid })
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

    if vol_ids.length == 1
      schedinfo = { "volumeID" => vol_ids[0] }
    else
      schedinfo = { "volumes" => vol_ids }
    end
    schedinfo['name'] = @resource[:snapname]
    schedinfo['retention'] = @resource[:retention]
    wkdys = []
    if @resource[:weekdays]
      @resource[:weekdays].each do |theday|
        wkdys << { "day" => theday, "offset" => 1 }
      end
    end
    params = { "scheduleName" => @resource[:name],
               "attributes" => { "frequency" => @resource[:attributes] },
               "hours"      => @resource[:hours],
               "minutes"    => @resource[:minutes],
               "recurring"  => @resource[:recurring],
               "monthdays"  => @resource[:monthdays],
               "startingDate" => @resource[:startdate],
               "scheduleType" => "snapshot",
               "paused"     => false,
               "scheduleInfo" => schedinfo,
               "weekdays"   => wkdys,
              }
    if schedid
      # schedule exists modify
      # got schedule as it exists, since we are here, we have checked it exists
      params["scheduleID"] = schedid
      transport(conn_info).ModifySchedule(params)
    else
      # schedule doesn't exist create
      Puppet.debug "Create snap schedule"
      schedid = transport(conn_info).CreateSchedule(params)['scheduleID']
    end
    schedid
  end

  def flush
    Puppet.debug("#{self.class}::flush")
    if sched_id = set_sched
      sched = transport(conn_info).GetSchedule({"scheduleID" =>
                        sched_id})['schedule']
      @property_hash = self.class.get_sched_properties(sched)
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
    elsif sched = transport(conn_info).getSchedByName(@resource[:name])
        @property_hash = self.class.get_sched_properties(sched)
        true
    else false end
  end

end
