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
# ==== Required
# [*ensurable*]
# [*username*]        - Account name (alias: name)
#
# ==== Optional
# [*initiatorsecret*] - Initiator CHAP secret.
# [*targetsecret*]    - Target CHAP secret.
#
# ==== Read-only
# [*accountid*]       - The cluster assigned account ID for this account.
#
# ==== Connection parameters
# [*url*]             - The connections URL as https://login:password@mvip
# [*login*]           - The cluster admin account
# [*password*]        - The cluster admin password
# [*mvip*]            - The cluster Management Virtual IP address (mvip)
#                       dns name works too.
#
#
solidfire_account { 'solidfireAccount':
  ensure        => 'present',
  initiatorsecret => 'inisecret123',
  targetsecret  => 'tgtsecret123',
  mvip          => '10.10.1.84',
  passwd        => 'solidfire',
  login         => 'admin',
  url           => 'https://admin:password@cluster.solidfire.com'
}
