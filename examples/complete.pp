#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/
#
# === README
# This is an example manifest to show how to use the SolidFire provider to
# create a volume on SolidFire and mount it to the puppet client. This
# manifest should not be run from a puppet device context.

$solidfire_url = 'https://admin:password@cluster2.solidfire.com'
$solidfire_svip = '10.10.1.83'

node 'client.localdomain' {
  # There are probably ways to dynamically determine the next disk
  # under which the volume will pop up. I'll leave that to the reader/user.
  $ourdisk = 'sdb'
  $disk_path = "/dev/${ourdisk}"
  $sf_account = $::fqdn

  # Volume and VAG names cannot have '.' in them so replace with '-'
  $sf_volume = regsubst("${sf_account}-${ourdisk}", '\.', '-', 'G')
  $sf_vag = regsubst($sf_account, '\.', '-', 'G')

  # There are a lot of different ways to solve this hard coding, none great!
  # I'll leave it as an excerise to the reader.
  $iqn = 'iqn.1994-05.com.redhat:1756d2fc488'

  notify { "Using [assuming] Disk: ${disk_path}": }
  notify { "SolidFire Account name: ${sf_account}": }
  notify { "SolidFire Volume name: ${sf_volume}": }
  notify { "SolidFire Volume Access group (VAG): ${sf_vag}": }
  # We need to have iscsiadm to make this work.
  package { 'iscsi-initiator-utils':
     ensure => 'installed',
  }
  # Create the account on the SolidFire, force the CHAP secrets from here
  # that way you could use them later. The cluster will fill them for you if
  # you don't set here, but then how do you get them back into puppet?
  solidfire_account { $sf_account:
     ensure => 'present',
     initiatorsecret => '123456initsecret',
     targetsecret => '123456tgtsecret',
     url => $solidfire_url,
  }
  # Create the Volume under the account just created (i.e. dependency).
  solidfire_volume { $sf_volume:
     ensure => 'present',
     size => 3,
     min_iops => 120,
     max_iops => 240,
     burst_iops => 270,
     accountname => $sf_account,
     url => $solidfire_url,
     require => Solidfire_account[$sf_account]
  }
  # We're using Volume access groups instead of CHAP because the array picks
  # the VolumeID and uses that as part of the IQN, which is returned and
  # avaliable to the puppet provider, but there is no way to access from the
  # manifest.
  solidfire_vag { $sf_vag:
     ensure => 'present',
     initiators => [$iqn],
     volumes => [$sf_volume],
     url => $solidfire_url,
     require => Solidfire_volume[$sf_volume],
  }
  # run iSCSI discovery on this node.  The sleep is required because this
  # takes some time in the background and the next steps start before ready.
  exec { 'iscsi_discovery':
     command => "iscsiadm -m discovery -t st -p ${solidfire_svip}:3260 -l;
sleep 4",
     unless  => "test -d /var/lib/iscsi/sendtargets/${solidfire_svip},3260",
     path => '/usr/bin:/usr/sbin',
     require => Solidfire_vag[$sf_vag],
  }
  # Where to mount... probably should be a variable.
  file { '/mnt/database/':
     ensure => 'directory',
  }
  # These next classes come from the puppet lvm class.
  # See https://forge.puppetlabs.com/puppetlabs/lvm for details.
  physical_volume { $disk_path:
    ensure => present,
    require => Exec['iscsi_discovery'],
  }
  volume_group { 'database_vg':
    ensure           => present,
    physical_volumes => $disk_path,
    require => Physical_volume[$disk_path],
  }
  logical_volume { 'database_lv':
    ensure       => present,
    volume_group => 'database_vg',
    size         => '2G',
    require      => Volume_group['database_vg'],
  }
  filesystem { '/dev/database_vg/database_lv':
    ensure  => present,
    fs_type => 'ext4',
    options => '-b 4096 -E stride=32,stripe-width=64',
    require => Logical_volume['database_lv'],
  }
  # There might be a way to do this from the filesystem statement.
  exec { 'mount':
    command => "mount /dev/database_vg/database_lv /mnt/database",
    path => '/usr/bin:/usr/sbin',
    require => Filesystem['/dev/database_vg/database_lv'],
  }
}


filebucket { main: server => "puppet-server.balduf.localdomain" }
# defaults
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }
