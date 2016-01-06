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
    super(value)
    @property_flush = {}
  end

  def set_account
    if @property_flush[:ensure] == :absent
      # delete account
      transport(conn_info).RemoveAccount( { "accountID" => @property_hash[:accountid] })
      return
    else
      begin
        acct = transport(conn_info).GetAccountByName({"username" => @resource[:username]})['account']
        acct_id = acct['accountID']
      rescue SolidfireApi::JSONRPCError => msg
        if msg.message.include? "xUnknownAccount"
           Puppet.debug "Create Account"
           acct_id = transport(conn_info).AddAccount({"username" => @resource[:username] })['accountID']
        end
      end
      transport(conn_info).ModifyAccount( { "accountID" => acct_id,
                     "initiatorSecret" => @resource[:initiatorsecret],
                     "targetSecret" => @resource[:targetsecret],
                   } )
      acct_id
    end
  end

  def flush
    Puppet.debug("#{self.class}::flush")
    if acct_id = set_account
      acct = transport(conn_info).GetAccountByID( {"accountID" => acct_id, })
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
    Puppet.debug("#{self.class}::exists?")
    if @property_hash[:ensure] == :present then true
    else
      begin
        account = transport(conn_info).GetAccountByName({"username" => @resource[:username]})['account']
      rescue
        false
      else
        @property_hash = self.class.get_account_properties(account)
        true
      end
    end
  end

end
