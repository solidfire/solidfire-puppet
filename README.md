## SolidFire Puppet Module

[![Puppet Forge](http://img.shields.io/puppetforge/v/solidfire/solidfire.svg)](https://forge.puppetlabs.com/solidfire/solidfire)

#### Table of Contents

  1. [Disclaimer](#disclaimer)
  2. [Overview](#overview)
  3. [Description](#description)
  4. [Setup](#setup)
    * [Connecting to a SolidFire Cluster](#connecting-to-a-solidfire-cluster)
  5. [Usage](#usage)
    * [Puppet Device](#puppet-device)
    * [Puppet Agent](#puppet-agent)
    * [Puppet Apply](#puppet-apply)
  6. [Limitations](#limitations)
  7. [Development](#development)

## Disclaimer

This provider is written as best effort and provides no warranty expressed or
implied. Please contact the author(s) via the SolidFire developer portal on
the [Puppet forum](http://developer.solidfire.com/forum/puppet) if you have
questions about this module before running or modifying.

## Overview

The SolidFire provider allows you to provision volumes on a SolidFire cluster
from either a puppet client or a puppet device proxy host. The provider also
provides facts and resource lists from SolidFire clusters. The provider has
been developed against CentOS 7.1 using Puppet-3.8.4. At this stage testing
is completely manual.

## Description

Using the `solidfire_account`, `solidfire_volume` and `solidfire_vag` types, one
can quickly provision remote storage and attach it via iSCSI (and FC) from a
SolidFire cluster to a client.

The provider utilizes the robust API (json-rpc) available on the SolidFire
storage clusters to remotely provision the necessary resources.

## Setup

### Connecting to a SolidFire Cluster

A connection to a SolidFire cluster is via the Management Virtual IP (MVIP)
address and through use of a Cluster Admin account. A connection string is
needed to inform the providers how to connect. The providers can get the
connection string from various locations (see Usage below) but the three
pieces of information necessary are:

  1. Cluster Admin account user name.
  2. Cluster Admin account password.
  3. MVIP address or DNS name.

If multiple connection options are provider to the provider, it will use them
in the following order:

  1. Any existing connection.
  2. A Facter-supplied URL.
  3. A user-supplied URL.
  4. A user-supplied user name, password and MVIP.

## Usage

### Puppet Device

The Puppet Network Device system is a way to configure devices' (switches,
routers, storage) which do not have the ability to run puppet agent on
the devices. The device application acts as a smart proxy between the Puppet
Master and the managed network device. To do this, puppet device will
sequentially connects to the master on behalf of the managed network device
and will ask for a catalog (a catalog containing only network device
resources). It will then apply this catalog to the said device by translating
the resources to orders the network device understands. Puppet device will
then report back to the master for any changes and failures as a standard node.

The SolidFire providers are designed to work with the puppet device concept and
in this case will retrieve their connection information from the `url` given
in Puppet's `device.conf` file. An example is shown below:

    [cluster1.solidfire.com]
      type Solidfire
      url https://admin:password@cluster1.solidfire.com

In the case of Puppet Device connection to the SolidFire is from the machine
running 'device' only.

### Puppet Agent

Puppet agent is the client/slave side of the puppet master/slave relationship.
In the case of puppet agent the connection information needs to be included in
the manifest supplied to the agent from the master or it could be included
in a custom fact passed to the client. The connection string may be supplied
as a URL or as the 3 independent pieces of information (login, password and
mvip). See the example manifests for details.

In the case of Puppet Agent, connections to the SolidFire array will be
initiated from every machine which utilizes the SolidFire puppet module this
way. This may be of security concern for some folks. This method however has
the most usefulness, since one can allocate a volume and mount it in a single
manifest with proper dependencies.

### Puppet Apply

Puppet apply is the client only application of a local manifest. Puppet apply
is supported similar to puppet agent by the SolidFire providers. With puppet
apply it is easy to pass a connection string through facter using evironment
variables and therefore this is the best method to use the providers to show
resources. As an example the following command will run a manifest supplied on
the command line:

    export FACTER_url=https://admin:password@cluster1.solidfire.com
    puppet resource solidfire_account test-account ensure=present

And this code will show the complete list of Volume configured on a SolidFire
cluster:

    export FACTER_url=https://admin:password@cluster1.solidfire.com
    puppet resource solidfire_volume


## Limitations

Puppet as a whole expects to be able to define everything about an environment,
and the concept of a smart appliance is foreign to it.  Therefore some aspects
of managing remote storage do not work well with Puppet. For example, the
SolidFire array creates a new volume ID for every volume, and uses that as part
of the IQN identifier for iSCSI. The SolidFire API and provider fetch both the
Volume ID and IQN, but puppet has no mechanism for passing that dynamically
created ID into the remainder of a manifest and puppet cannot dictate the
Volume ID as it is a critical part of how SolidFire functions.

We have chosen in our example manifest to utilize Volume Access Groups as an
example work around the above limitation. We have left it as an exercise to the
users to find other creative workarounds. Please see the [development](#development)
section below to provide feedback and improved options.

The providers today use version 7.0 of the SolidFire API, which introduces
some additional compatibility, but also is slightly less efficient in some of
it's operations.

## Development

Please see the [Puppet forum](http://developer.solidfire.com/forum/puppet) on
the [SolidFire Developer Portal](https://developer.solidfire.com) for any issues,
discussion, advice or contribution(s).

To get started with developing this module, you'll need a functioning Ruby installation
with Bundler. Afterward, ensure you have the necessary dependencies and run some tests:

    $ bundle install
    $ bundle exec rake test

Happy hacking!
