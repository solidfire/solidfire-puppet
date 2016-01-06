# Example manifest to use the solidfire_volume class
#
# Parameters:
#
# [*ensure*}
#  The resource state
#
# [*mvip*]
#  The Management Virtual IP of the SolidFire cluster
#
# [*passwd*]
#  The password for the cluster admin account
#
# [*login*]
#  The cluster admin account to use to create the volumes
#
# [*volsize*]
#  Size of the volume
#
# [*min_iops*]
#  The minimum IOP guarantee for the volume
#
# [*max_iops*]
#  The maximum IOP limit for the volume
#
# [*burst_iops*]
#  The burst IOP limit for the volume
#
#
solidfire_volume { 'volumeName': 
  ensure        => 'present', 
  mvip          => '10.10.1.84',
  passwd        => 'solidfire',
  login         => 'admin', 
  volsize       => 3, 
  account       => 'solidfireAccount', 
  min_iops      => 420, 
  max_iops      => 520, 
  burst_iops    => 610
}
