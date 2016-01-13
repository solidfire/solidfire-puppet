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
