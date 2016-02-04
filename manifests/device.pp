# = Define: solidfire::device
#
# Manages the installation of a SolidFire cluster on a Puppet node's device.conf.
#
# This defined type should be used on a proxy node that manages the SolidFire cluster(s).
#
# == Parameters:
#
# [*hostname*]
#   The MVIP or DNS name of the SolidFire Cluster.
#
# [*username*]
#   The username/login for the SolidFire API.
#
# [*password*]
#   The password for the SolidFire API.
#

define solidfire::device (
  $hostname,
  $username,
  $password,
  $target = undef,
) {
  validate_string($hostname)
  validate_string($username)
  validate_string($password)

  $device_config = pick($target, $::settings::deviceconfig)

  validate_absolute_path($device_config)

  augeas { "device.conf/${name}":
    lens    => 'Puppet_Device',
    incl    => $device_config,
    context => $device_config,
    changes => [
      'set ${name}/type SolidFire',
      "set ${name}/url https://${username}:${password}@${hostname}",
    ]
  }
}
