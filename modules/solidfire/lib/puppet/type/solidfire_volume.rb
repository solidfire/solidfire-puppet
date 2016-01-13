Puppet::Type.newtype(:solidfire_volume) do
  @doc = "Manage Volumes on solidfire cluster"

#Ranges for the IOPS values
MINIOPS_MIN = 100
MINIOPS_MAX = 15000
MAXIOPS_MIN = 100
MAXIOPS_MAX = 100000
BURSTIOPS_MIN = 100
BURSTIOPS_MAX = 100000

  apply_to_all

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of the volume (1-64 characters)"
    validate do |value|
      fail("Name too long #{value}") unless value.length.between?(1, 64)
    end
  end

  newproperty(:accountname) do
   desc "The account name to create the volume under."
  end

  newproperty(:size) do
    desc "The size of the volume in GB"
  end

  newproperty(:min_iops) do
    validate do |value|
      fail("min_iops not within valid range " \
           "#{MINIOPS_MIN}..#{MINIOPS_MAX}") unless \
           value.to_i.between?(MINIOPS_MIN, MINIOPS_MAX)
    end
  end

  newproperty(:max_iops) do
    validate do |value|
      fail("max_iops not within valid range " \
           "#{MAXIOPS_MIN}..#{MAXIOPS_MAX}") unless \
           value.to_i.between?(MAXIOPS_MIN, MAXIOPS_MAX)
    end
  end

  newproperty(:burst_iops) do
    validate do |value|
      fail("burst_iops not within valid range " \
           "#{BURSTIOPS_MIN}..#{BURSTIOPS_MAX}") unless \
           value.to_i.between?(BURSTIOPS_MIN, BURSTIOPS_MAX)
    end
  end

  newproperty(:volumeid) do
    desc "VolumeID supplied by the cluster."
    validate do |value|
      fail "volumeid is read-only"
    end
  end

  newproperty(:iqn) do
    desc "IQN supplied by the cluster."
    validate do |value|
      fail "iqn is read-only"
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
