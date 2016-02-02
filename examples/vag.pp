#====================================================================
# Disclaimer: This script is written as best effort and provides no
# warranty expressed or implied. Please contact the author(s) if you
# have questions about this script before running or modifying
#====================================================================
# See the puppet forum on http://http://developer.solidfire.com/
#
# Example manifest to use the solidfire_vag class
#
# Parameters:
#
# ==== Required
# [*ensurable*]
# [*name*]            - Volume access group name (only letters and - allowed)
# [*initiators*]      - Array of the iscsi initiators allowed
# [*volumes*]         - Array of the volume names allowed
#
# ==== Optional
#
# ==== Read-only
# [*vagid*]           - The cluster assigned VAG ID for this VAG.
#
# ==== Connection parameters
# [*url*]             - The connections URL as https://login:password@mvip
# [*login*]           - The cluster admin account
# [*password*]        - The cluster admin password
# [*mvip*]            - The cluster Management Virtual IP address (mvip)
#                       dns name works too.
#
#
solidfire_vag { 'solidfirevolumeaccesgroup':
  ensure        => 'present',
  initiators    => ['iqn.1994-05.com.rhat:1788', 'iqn.1994-05.com.rhat:1758'],
  volumes       => ['volumename1', 'volumename2'],
  mvip          => '10.10.1.84',
  passwd        => 'solidfire',
  login         => 'admin',
  url           => 'https://admin:password@cluster.solidfire.com'
}
