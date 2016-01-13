Puppet::Type.newtype(:solidfire_account) do
  @doc = "Manage Accounts on solidfire cluster"

  apply_to_all

  ensurable

  newparam(:username) do
    desc "The username of the account (1-64 characters)"
    isnamevar
    validate do |value|
      fail("Username too long #{value}") unless value.length.between?(1, 64)
    end
  end

  newproperty(:initiatorsecret) do
    desc "The initiator CHAP secret (12-16 chracters)"
    validate do |value|
      fail("Initiator secret too short/long #{value}") unless \
            value.length.between?(12, 16)
    end
  end

  newproperty(:targetsecret) do
    desc "The target CHAP secret (12-16 chracters)"
    validate do |value|
      fail("Target secret too short/long #{value}") unless \
           value.length.between?(12, 16)
    end
  end

  newproperty(:accountid) do
    desc "AccountID is supplied by the cluster."
    validate do |val|
      fail "accountid is read-only"
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
