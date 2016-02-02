#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/
#
# Example manifest to use the solidfire_volume class
#
# Parameters:
#
# ==== Required
# [*ensurable*]
# [*name*]            - The volume name ( only letters numbers and - allowed)
# [*accountname*]     - The account name this volume should live within
# [*size*]            - Size of the volume in GB
#
# ==== Optional
#       (IOPS parameters default to cluster defaults if undefined)
# [*min_iops*]        - The minimum IOP guarantee for the volume
#                       (range 100-15,000)
# [*max_iops*]        - The maximum IOP limit for the volume
#                       (range 100-100,000)
# [*burst_iops*]      - The burst IOP limit for the volume
#                       (range 100-100,000)
#
# ==== Read-only
# [*volumeid*]        - The cluster assigned volume ID for this volume.
# [*iqn*]             - The cluster assigned iSCSI IQN for this volume.
#
# ==== Connection parameters
# [*url*]             - The connections URL as https://login:password@mvip
# [*login*]           - The cluster admin account
# [*password*]        - The cluster admin password
# [*mvip*]            - The cluster Management Virtual IP address (mvip)
#                       dns name works too.
#
#
solidfire_volume { 'volumeName':
  ensure        => 'present',
  accountname   => 'solidfireAccount',
  size          => 3,
  min_iops      => 420,
  max_iops      => 520,
  burst_iops    => 610,
  mvip          => '10.10.1.84',
  passwd        => 'solidfire',
  login         => 'admin',
  url           => 'https://admin:password@cluster.solidfire.com'
}
