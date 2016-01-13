#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/
#
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
