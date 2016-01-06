Puppet::Type.newtype(:solidfire_volume) do
  @doc = "Manage Volumes on solidfire cluster"

  apply_to_all

  ensurable

  newparam(:name, :namevar => true) do
  end

  newparam(:accountname) do
  end

  newproperty(:size) do
  end

  newproperty(:min_iops) do
  end

  newproperty(:max_iops) do
  end

  newproperty(:burst_iops) do
  end

  newproperty(:volumeid) do
  end

  #  These are on every SolidFire type

  newparam(:mvip) do
  end

  newparam(:login) do
  end

  newparam(:password) do
  end

  newparam(:url) do
  end

end
