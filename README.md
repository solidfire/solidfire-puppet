## SolidFire Puppet

#### Table of Contents

1. [Disclaimer](#disclaimer)
2. [Overview](#overview)
3. [Provider Description - What the provider does and why.](#description)
4. Setup - The basics
    * [Connection to SolidFire](#connection)
5. Usage - Configuration options
    * [Puppet device](#device)
    * [Puppet agent](#agent)
    * [Puppet apply](#apply)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## <a name="disclaimer"></a> Disclaimer

This provider is written as best effort and provides no warranty expressed or
implied. Please contact the author(s) via the SolidFire developer portal on
the [Puppet forum](http://developer.solidfire.com/forum/puppet) if you have
questions about this module before running or modifying.

## <a name="overview"></a> Overview

The SolidFire provider allows you to provision volumes on a SolidFire cluster
from either a puppet client or a puppet device proxy host. The provider also
provides facts and resource lists from SolidFire clusters. The provider has
been developed against CentOS 7.1 using Puppet-3.8.4. At this stage testiing
is compeletely manual.

## <a name="description"></a> Provider Description

Using the solidfire\_account, solidfire\_volume and solidfire\_vag types, one
can quickly provision remote storage and attach it via iSCSI (and FC) from a
SolidFire cluster to a client.

The provider utilizes the robust API (json-rpc) available on the SolidFire
storage clusters to remotely provision the necessary resources.

## Basics

### <a name="connection"></a> Connection to SolidFire

A connection to a SolidFire cluster is via the Management Virtual IP (MVIP)
address and through use of a Cluster Admin account. A connection string is
needed to inform the providers how to connect. The providers can get the
connection string from various locations (see Usage below) but the three
pieces of information necessary are 1) Cluster Admin account name 2) Cluster
admin password and 3) MVIP address or dns name.

IF multiple connection options are provider to the provider, it will use them
in the following order:

1. Existing Connection
2. Facter supplied url
3. User supplied url
4. User supplied login, password and mvip

## Usage

### <a name="device"></a> Puppet device

The Puppet Network Device system is a way to configure devices' (switches,
routers, storage) which do not have the ability to run puppet agent on
the devices. The device application acts as a smart proxy between the Puppet
Master and the managed network device. To do this, puppet device will
sequentially connects to the master on behalf of the managed network device
and will ask for a catalog (a catalog containing only network device
resources). It will then apply this catalog to the said device by translating
the resources to orders the network device understands. Puppet device will
then report back to the master for any changes and failures as a standard node.

The SolidFire providers are designe to work with the puppet device concept and
in this case will retreive their connection information from the _url_ given
in the device.conf file, ane Example of which is shown below:

    [cluster1.solidfire.com]
      type Solidfire
      url https://admin:password@cluster1.solidfire.com

In the case of Puppet Device connection to the SolidFire is from the machine
running 'device' only.

### <a name="agent"></a> Puppet agent

Puppet agent is the client/slave side of the puppet master/slave relationship.
In the case of puppet agent the connection inforation needs to be included in
the manifest supplied to the agenet from the master _or_ it could be included
in a custome Facter built and passed to the client. The connection string may
be supplied as a URL or as the 3 independent pieces of information (login,
password and mvip), see example manifests for details.

In the case of Puppet Agent, connections to the SolidFire array will be
initiatied from every machine which utilizes the SolidFire puppet module this
way. This may be of security concern for some folks. This method however has
the most usefullness, since one can allocate a volume and mount it in a single
manifest with proper depenedencies.

### <a name="apply"></a> Puppet apply

Puppet apply is the client only application of a local manifest. Puppet apply
is supported similar to puppet agent by the SolidFire providers. With puppet
apply it is easy to pass a connection string through facter using evironment
variables and therefore this is the best method to use the providers to show
resources. As an example the following command will run a manifest supplied on
the command line:

    FACTER\_url=https://admin:password@cluster1.solidfire.com puppet apply \
    -e "solidfire\_account { 'test-account': ensure => 'present'}"

And this code will show the complete list of Volume configured on a SolidFire
cluster:

    FACTER\_url=https://admin:password@cluster1.solidfire.com puppet \
    resource solidfire_volume


## <a name="Limitations"></a> Limitations

Puppet as a whole expects to be able to define everything about an
environment, and the concept of a smart appliance is foreign to it.  Therefore
some aspects of managing remote storage do not work well with Puppet. For
example, the SolidFire array creates a new volume ID for every volume, and
uses that as part of the IQN identifier for iSCSI. The SolidFire API and
provider fetch both the Volume ID and IQN, but puppet has no mechanism for
passing that dynamically created ID into the remainder of a manifest and
puppet cannot dictate the Volume ID as it is a critical part of how SolidFire
functions.

We have choosen in our example manifest to utilize Volume Access Groups as an
example work around the above limitation. We have left it as an excecise to
the users to find other creative work arounds. Please see the
[development](#development) section below to provide feedback and improved options.

The providers today use version 7.0 of the SolidFire API, which introduces
some additional compatibility, but also is slightly less efficient in some of
it's operations.

## <a name="development"></a> Development

Please see the [Puppet forum](http://developer.solidfire.com/forum/puppet) on
<https://developer.solidfire.com> for any issues (best effort help),
discussion, advice or if you have a contribution.
