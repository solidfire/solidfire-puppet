# Example manifest to use the solidfire_account class
#
# Parameters:
#
# [*ensure*}
#  The resource state
#
#
solidfire_account { 'solidfireAccount': 
  ensure        => 'present', 
  mvip          => '10.10.1.84',
  passwd        => 'solidfire',
  login         => 'admin', 
}
