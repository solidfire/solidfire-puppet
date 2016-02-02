#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/

require 'date'

Puppet::Type.newtype(:solidfire_snapsched) do
  @doc = "Manage Volume snapshot schedules on a solidfire cluster"

  apply_to_all

  ensurable

  newparam(:name) do
    desc "The name of the snapshot schedule (1-64 characters)"
    isnamevar
    validate do |value|
      fail("Schedule Name too long #{value}") unless value.length.between?(1, 64)
    end
  end

  newproperty(:snapname) do
    desc <<-EOT
      This is the name that will be given to the snapshots produced by
      this schedule.
    EOT
    validate do |value|
      fail("snapshot name too long #{value}") unless value.length.between?(1, 64)
    end
  end

  newproperty(:volumes, :array_matching => :all) do
    desc "List of Volume Names to include in the Snapshot."
  end

  newproperty(:attributes) do
    desc "The Frequency Object"
    newvalues("Days of Week", "Days of Month", "Time Interval")
  end

  newproperty(:hours) do
    validate do |value|
      fail("Hours not between 0-23.") unless value.to_i.between?(0,23)
    end
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:minutes) do
    validate do |value|
      fail("Minutes not between 0-59.") unless value.to_i.between?(0,59)
    end
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:recurring) do
    desc "Indicates if the schedule will be recurring or not"
    defaultto :true
    newvalues(:true, :false)
    munge do |value|
      case value
      when true, :true, "true"; true
      when false, :false, "false"; false
      end
    end
  end

  newproperty(:retention) do
    desc "The amount of time the snapshot will be retained HH:mm:ss"
    validate do |value|
      fail("Retention not in the correct format") unless
          value.split(":").count == 3
    end
  end

  newproperty(:startdate) do
    desc <<-EOT
      The time after which the schedule will be run. If not set start
      imediately. the format should be standard ruby datetime
      (ex: 2016-02-01T10:59:33-07:00)
    EOT
    validate do |value|
      fail("invalid datatime in startdate") if ((DateTime.parse(value) rescue ArgumentError) == ArgumentError)
    end
  end

  newproperty(:monthdays, :array_matching => :all) do
    desc "Array of the days of the month to run 1-31"
    validate do |value|
      value = [value] unless value.is_a?(Array)
      value.each do |avalue|
        fail("monthdays not between 1-31.") unless avalue.to_i.between?(1,31)
      end
    end
  end

  newproperty(:weekdays, :array_matching => :all) do
    desc "Array of the days of the week to run 0-6 (Sunday - Saturday)"
    validate do |value|
      value = [value] unless value.is_a?(Array)
      value.each do |avalue|
        fail("days of the week not between 0-6") unless avalue.to_i.between?(0,6)
      end
    end
  end

  newproperty(:schedid) do
    desc "schedid is supplied by the cluster."
    validate do |value|
      fail "schedid is read-only"
    end
  end

  #  These are on every SolidFire type

  newparam(:mvip) do
    desc "The Management Virtual IP address."
  end

  newparam(:login) do
    desc "The cluster admin login to use."
  end

  newparam(:password) do
    desc "The password for the Cluster admin."
  end

  newparam(:url) do
    desc "If using URL do not use mvip, login, and password. "\
         "URL in the form of https://acct:passwd@mvip/ "
  end

end
