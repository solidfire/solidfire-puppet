$solidfire_url = 'https://admin:solidfire@sf.balduf.localdomain'
$solidfire_svip = '10.10.1.83'
$disk_path = '/dev/sdb'

node 'client.localdomain' {
  solidfire_account { 'puppet-test':
     ensure => 'present',
     initiatorsecret => '123456initsecret',
     targetsecret => '123456tgtsecret',
     url => $solidfire_url,
  }
  solidfire_volume { 'p-test2':
     ensure => 'present',
     size => 3,
     min_iops => 120,
     max_iops => 240,
     burst_iops => 270,
     accountname => 'puppet-test',
     url => $solidfire_url,
     require => Solidfire_account['puppet-test']
  }
  solidfire_vag { 'p-test2-vag':
     ensure => 'present',
     initiators => ['iqn.1994-05.com.redhat:1756d2fc488'],
     volumes => ['p-test2'],
     url => $solidfire_url,
     require => Solidfire_volume['p-test2'],
  }
  exec { 'iscsi_discovery':
     command => "iscsiadm -m discovery -t st -p $solidfire_svip -l; sleep 10",
     path => '/usr/bin:/usr/sbin',
     require => Solidfire_vag['p-test2-vag'],
  }
  file { '/mnt/database/':
     ensure => 'directory',
  }
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
