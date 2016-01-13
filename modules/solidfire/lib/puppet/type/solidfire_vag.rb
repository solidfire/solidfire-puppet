#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/

Puppet::Type.newtype(:solidfire_vag) do
  @doc = "Manage Volume Access Groups on solidfire cluster"

  apply_to_all

  ensurable

  newparam(:name) do
    desc "The name of the Volume Access Group (1-64 characters)"
    isnamevar
    validate do |value|
      fail("VAG Name too long #{value}") unless value.length.between?(1, 64)
    end
  end

  newproperty(:initiators, :array_matching => :all) do
    desc "List of initiators to include in the Volume Access Group"
  end

  newproperty(:volumes, :array_matching => :all) do
    desc "List of Volume Names to include in the Volume Access Group"
  end

  newproperty(:vagid) do
    desc "VagID is supplied by the cluster."
    validate do |value|
      fail "VAGid is read-only"
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
