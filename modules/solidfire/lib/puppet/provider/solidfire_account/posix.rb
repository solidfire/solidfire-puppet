require 'puppet/provider/solidfire'
require 'puppet/util/network_device'

Puppet::Type.type(:solidfire_account).provide(:posix, :parent => Puppet::Provider::Solidfire) do
  desc "Manage SolidFire account creation and deletion."
  confine :feature => :posix

  mk_resource_methods

  def self.instances
    Puppet.debug("#{self.class}::self.instances.")
    users = []
    begin
      accountlist = transport.ListAccounts()['accounts']
    rescue Puppet::Error
      users
    else
      accountlist.each do |user|
        user_hash = get_account_properties(user)
        Puppet.debug("user -> #{user_hash}")
        users << new(user_hash)
      end
      users
    end
  end

  def self.prefetch(resources)
    Puppet.debug("#{self.class}::self.prefetch.")
    instances.each do |prov|
      if resource = resources[prov.username]
        resource.provider = prov
      end
    end
  end

  def self.get_account_properties(acct)
    acct_hash = { :username          => acct['username'],
                  :name              => acct['username'],
                  :ensure            => :present,
                  :initiatorsecret   => acct['initiatorSecret'],
                  :targetsecret      => acct['targetSecret'],
                  :accountid         => acct['accountID'],
                 }
  end

  def initialize(value={})
    Puppet.debug("#{self.class}::initialize #{value}")
    super(value)
    @property_flush = {}
  end

  def set_account
    if @property_flush[:ensure] == :absent
      # account is being deleted ... delete
      transport.RemoveAccount( { "accountID" => @property_hash[:accountid] })
      return
    end
    acct_id = transport.AddAccount({"username" => resource[:username] })['accountID']
    transport.ModifyAccount( { "accountID" => acct_id,
                     "initiatorSecret" => resource[:initiatorsecret],
                     "targetSecret" => resource[:targetsecret],
                   } )
    acct_id
  end

  def flush
    Puppet.debug("#{self.class}::flush")
    begin
      transport
    rescue
      transport("https://" + resource[:login] + ":" + resource[:password] + \
                "@" + resource[:mvip] + "/" )
    end
    if acct_id = set_account
      acct = transport.GetAccountByID( {"accountID" => acct_id, })
      @property_hash = self.class.get_account_properties(acct)
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
        account = transport("https://" + resource[:login] + ":" + \
                  resource[:password] + "@" + resource[:mvip] + "/" ).
                  GetAccountByName({"username" => @resource[:username]})['account']
      rescue
      end
      if account
        @property_hash = self.class.get_account_properties(account)
        true
      else
        false
      end
    end
  end

end
